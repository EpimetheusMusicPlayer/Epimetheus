import 'dart:async';

import 'package:async/async.dart';
import 'package:epimetheus/features/auth/entities/auth_status.dart';
import 'package:epimetheus/features/collection/entities/collected_item.dart';
import 'package:epimetheus/features/playback/services/audio_task/audio_task.dart';
import 'package:epimetheus/features/playback/services/audio_task/media_sources/station/station_media_source.dart';
import 'package:epimetheus_nullable/mobx/api/api_store.dart';
import 'package:epimetheus_nullable/mobx/auth/auth_store.dart';
import 'package:epimetheus_nullable/mobx/reactive_store.dart';
import 'package:iapetus/iapetus.dart';
import 'package:meta/meta.dart';
import 'package:mobx/mobx.dart';
import 'package:pedantic/pedantic.dart';

part 'collection_store.g.dart';

class CollectionStore = _CollectionStore with _$CollectionStore;

abstract class _CollectionStore extends ReactiveStore with Store {
  final AuthStore _authStore;

  final StationStore stations;
  final Map<Type, CategoryStore> _categories;

  _CollectionStore({
    @required ApiStore apiStore,
    @required AuthStore authStore,
    int pageSize = 24,
    int playlistPageSize = 100,
  })  : _authStore = authStore,
        stations = StationStore(
          apiStore: apiStore,
        ),
        _categories = {
          Playlist: CategoryStore<Playlist, PlaylistAnnotation>(
            apiStore: apiStore,
            typeName: 'playlist',
            filterTypes: const [CollectionFilterType.playlists],
            pageSize: playlistPageSize,
          ),
          Artist: CategoryStore<Artist, ArtistAnnotation>(
            apiStore: apiStore,
            typeName: 'artist',
            filterTypes: const [CollectionFilterType.artists],
            pageSize: pageSize,
          ),
          Album: CategoryStore<Album, AlbumAnnotation>(
            apiStore: apiStore,
            typeName: 'album',
            filterTypes: const [CollectionFilterType.albums],
            pageSize: pageSize,
          ),
          Song: CategoryStore<Song, SongAnnotation>(
            apiStore: apiStore,
            typeName: 'song',
            filterTypes: const [CollectionFilterType.songs],
            pageSize: pageSize,
          ),
        },
        pageSize = pageSize,
        playlistPageSize = playlistPageSize;

  @observable
  int pageSize;

  @observable
  int playlistPageSize;

  CategoryStore<I, A>
      getCategoryStore<I extends CollectionItem, A extends Annotation>() {
    assert(
      _categories.containsKey(I),
      'Category store does not exist for type $I!',
    );
    return _categories[I];
  }

  @override
  List<ReactionDisposer> initReactions() {
    return [
      autorun((_) async {
        switch (_authStore.authState.status) {
          case AuthStatus.loggedIn:
            unawaited(stations.loadStations());
            for (final category in _categories.values) {
              unawaited(category.loadFirstPage());
            }
            return;
          case AuthStatus.loggedOut:
            stations.clear();
            for (final category in _categories.values) {
              category.clear();
            }
            return;
          default:
            return;
        }
      }),
    ];
  }
}

abstract class RemoteListStore<ListType> = _RemoteListStore<ListType>
    with _$RemoteListStore<ListType>;

abstract class _RemoteListStore<ListType> with Store {
  /// The loaded items. Must be observable.
  List<ListType> get loadedItems;

  @protected
  set loadedItems(List<ListType> value);

  @observable
  String errorMessage;

  CancelableOperation<void> _cancelableLoadingOperation;

  @observable
  ObservableFuture<void> _observableLoadingFuture;

  @computed
  bool get isLoading =>
      _observableLoadingFuture?.status == FutureStatus.pending;

  @computed
  bool get hasError => errorMessage != null;

  @computed
  bool get anyItemsLoaded {
    return loadedItems != null;
  }

  @protected
  @action
  Future<void> load<T>({
    @required Future<T> Function() get,
    @required String Function(T data) use,
    @required void Function() onError,
  }) async {
    // Cancel any existing load operations (unawaited as once the cancel starts,
    // a new object is assigned, and the cancel can continue in the background on
    // the old object.
    unawaited(_cancelableLoadingOperation?.cancel());

    // Start the loading operation.
    final loadingFuture = get();

    // Set up a function to clear the future variables.
    void clearFutures() {
      _observableLoadingFuture = null;
      _cancelableLoadingOperation = null;
    }

    // Create an observable future from the loading future.
    _observableLoadingFuture = loadingFuture.asObservable();

    // Create the cancelable loading operation from the loading future.
    final cancelableLoadingOperation =
        CancelableOperation<T>.fromFuture(loadingFuture);

    // Set the _cancelableLoadingOperation property to use the created
    // cancelable operation with extra actions to clear futures, call "use",
    // and catch errors.
    _cancelableLoadingOperation = cancelableLoadingOperation.then(
      (data) {
        clearFutures();
        errorMessage = use(data);
      },
      onError: (e, s) {
        final errorMessage = _handleError(e);
        clearFutures();
        if (errorMessage == null) {
          // TODO use proper log system here
          print('Error loading remote list data:\n$s');
          throw e;
        } else {
          this.errorMessage = errorMessage;
          onError();
        }
      },
      onCancel: () {
        cancelableLoadingOperation.cancel();
        clearFutures();
      },
    );

    // Await the loading future (ignoring all errors, as they're handled by the
    // code above).
    await loadingFuture.catchError((e) {});
  }

  @action
  void clear() {
    _cancelableLoadingOperation?.cancel();
    _cancelableLoadingOperation = null;
    _observableLoadingFuture = null;
    errorMessage = null;
    loadedItems = null;
  }

  /// Checks the given error (not a literal [Error] object, returning an error
  /// string if the error is expected.
  ///
  /// Returns null otherwise.
  String _handleError(dynamic e) {
    if (e is IapetusNetworkException) {
      return 'Could not connect to the network.';
    } else if (e is InvalidAuthException) {
      return 'Authentication error; has your password changed?';
    } else if (e is UnknownPandoraErrorException) {
      return e.toString();
    }

    return null;
  }
}

// Weird inheritance going on here: https://github.com/mobxjs/mobx.dart/issues/594
class StationStore = _StationStore with _$StationStore;

abstract class _StationStore extends RemoteListStore<Station> with Store {
  final ApiStore _apiStore;

  _StationStore({
    @required ApiStore apiStore,
    this.sortOrder = StationSortOrder.lastPlayed,
  }) : _apiStore = apiStore;

  @observable
  StationSortOrder sortOrder;

  @observable
  List<Station> _unsortedLoadedItems;

  @override
  set loadedItems(List<Station> value) => _unsortedLoadedItems = value;

  @override
  @computed
  List<Station> get loadedItems => _unsortedLoadedItems?.sortBy(sortOrder);

  Future<void> loadStations() async {
    assert(
      _apiStore.loggedIn,
      'Cannot load stations; not logged in!',
    );

    await load(
      get: _apiStore.api.getStations,
      use: (data) {
        loadedItems = data;
        return null;
      },
      onError: () {
        // Set the loaded items to null; the old ones shouldn't be used anymore.
        loadedItems = null;
      },
    );
  }

  Future<void> refresh() => loadStations();

  Future<void> removeStation(Station station) async {
    await load<void>(
      get: () => station.removeFromCollection(_apiStore.api),
      use: (_) => null,
      onError: () {},
    );

    unawaited(refresh());
  }

  /// Renames the station at the given [index].
  /// Returns a [String] if an exception is caught, and null otherwise.
  Future<String> renameStation(int index, String name) async {
    try {
      await loadedItems[index].rename(_apiStore.api, name);
    } catch (e) {
      final errorMessage = _handleError(e);
      if (errorMessage == null) rethrow;
      return errorMessage;
    }

    unawaited(refresh());
    return null;
  }

  // Plays the station at the given index.
  void xbox(int index) {
    AudioTask.launchMediaSource(
      StationMediaSource(loadedItems[index]),
      _apiStore.api,
    );
  }
}

// Weird inheritance going on here: https://github.com/mobxjs/mobx.dart/issues/594
class CategoryStore<I extends CollectionItem,
    A extends Annotation> = _CategoryStore<I, A> with _$CategoryStore<I, A>;

abstract class _CategoryStore<I extends CollectionItem, A extends Annotation>
    extends RemoteListStore<CollectedItem<I, A>> with Store {
  final ApiStore _apiStore;
  final String typeName;
  final List<CollectionFilterType> _filterTypes;
  final int pageSize;

  _CategoryStore({
    @required ApiStore apiStore,
    @required this.typeName,
    @required List<CollectionFilterType> filterTypes,
    @required this.pageSize,
  })  : _apiStore = apiStore,
        _filterTypes = filterTypes;

  @override
  @observable
  List<CollectedItem<I, A>> loadedItems;

  @observable
  PagedCollectionSegment<I> _loadedSegment;

  @computed
  int get nextPageOffset {
    if (loadedItems == null) return 0;
    if (loadedItems.length >= _loadedSegment.totalCount) return null;
    return loadedItems.length;
  }

  Future<void> loadFirstPage() async {
    await load<PagedCollectionSegment<I>>(
      get: () => _apiStore.api.getPagedCollectionSegment<I>(
        filterTypes: _filterTypes,
        pageSize: pageSize,
        offset: 0,
      ),
      use: (data) {
        _loadedSegment = data;
        loadedItems = [
          for (final item in data.items)
            CollectedItem(
              item,
              _loadedSegment.annotations[item.pandoraId],
            ),
        ];
        return null;
      },
      onError: () {
        // Set the loaded items to null; the old ones shouldn't be used anymore,
        // as a new page was requested.
        _loadedSegment = null;
        loadedItems = null;
      },
    );
  }

  Future<void> requestPageAt(int offset) async {
    // The requested page is either already loaded or too far ahead; do nothing.
    if ((loadedItems?.length ?? 0) != offset) return;

    // We're good to go; do the real action.
    await _requestPageAt(offset);
  }

  Future<void> _requestPageAt(int offset) async {
    if (offset == 0) return await loadFirstPage();
    await load<PagedCollectionSegment<I>>(
      get: () => _loadedSegment.getNextPage(_apiStore.api),
      use: (data) {
        if (data.totalCount == _loadedSegment.totalCount) {
          _loadedSegment += data;
          loadedItems = [
            ...loadedItems,
            for (final item in data.items)
              CollectedItem(
                item,
                data.annotations[item.pandoraId],
              ),
          ];
          return null;
        } else {
          // The collection has been modified by another app if this happens.
          // TODO this is glitchy;
          return 'Your $typeName list has changed unexpectedly.';
        }
      },
      onError: () {
        // Unlike the station list implementation, the old data is not useless;
        // No new page will be added, but the old ones can remain.
        // Nothing is cleared here.
      },
    );
  }

  @action
  Future<void> refresh() async {
    unawaited(_cancelableLoadingOperation?.cancel());
    _cancelableLoadingOperation = null;
    _observableLoadingFuture = null;
    await loadFirstPage();
  }

  /// Performs a modification on a collection category list, catching expected
  /// errors. Returns an error message [String] if an error is caught, and null
  /// otherwise.
  Future<String> modifyCollection(
      Future<void> Function(Iapetus api) modify) async {
    try {
      await modify(_apiStore.api);
    } catch (e) {
      final errorMessage = _handleError(e);
      if (errorMessage == null) rethrow;
      return errorMessage;
    }

    // Cannot refresh here due to a bug in the pagination UI widget.
    // For now, refreshing is done manually by the UI as a result.
    // unawaited(refresh());

    return null;
  }

  Future<String> add(Annotation annotation) {
    return modifyCollection(
      (api) {
        // Clear the collection before modifying.
        // When the refreshing logic is moved back into this store,
        // a refresh will be required as well.
        clear();
        return annotation.addToCollection(api);
      },
    );
  }

  Future<String> remove(Annotation annotation) {
    return modifyCollection(
      (api) {
        // Delete the removed item from the list before it finishes loading.
        // This is a bit of a dirty hack; Iapetus is made with immutable structures
        // at its core. As loadedItems is a mutable list stored in this store only,
        // however, this isn't too bad.
        //
        // Scratch the above; this can cause the UI to request pages when it
        // shouldn't due to the computed nextPageOffset changing. Clear the
        // whole collection instead for now.
        // TODO think of a better solution.
        // loadedItems = List.of(loadedItems)
        //   ..removeAt(loadedItems.indexWhere((collectedItem) =>
        //       collectedItem.annotation.pandoraId == annotation.pandoraId));
        clear();

        // Do the actual remove
        return annotation.removeFromCollection(api);
      },
    );
  }
}
