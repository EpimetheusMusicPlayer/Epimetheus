// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$CollectionStore on _CollectionStore, Store {
  final _$pageSizeAtom = Atom(name: '_CollectionStore.pageSize');

  @override
  int get pageSize {
    _$pageSizeAtom.reportRead();
    return super.pageSize;
  }

  @override
  set pageSize(int value) {
    _$pageSizeAtom.reportWrite(value, super.pageSize, () {
      super.pageSize = value;
    });
  }

  final _$playlistPageSizeAtom =
      Atom(name: '_CollectionStore.playlistPageSize');

  @override
  int get playlistPageSize {
    _$playlistPageSizeAtom.reportRead();
    return super.playlistPageSize;
  }

  @override
  set playlistPageSize(int value) {
    _$playlistPageSizeAtom.reportWrite(value, super.playlistPageSize, () {
      super.playlistPageSize = value;
    });
  }

  @override
  String toString() {
    return '''
pageSize: ${pageSize},
playlistPageSize: ${playlistPageSize}
    ''';
  }
}

mixin _$RemoteListStore<ListType> on _RemoteListStore<ListType>, Store {
  Computed<bool> _$isLoadingComputed;

  @override
  bool get isLoading =>
      (_$isLoadingComputed ??= Computed<bool>(() => super.isLoading,
              name: '_RemoteListStore.isLoading'))
          .value;
  Computed<bool> _$hasErrorComputed;

  @override
  bool get hasError =>
      (_$hasErrorComputed ??= Computed<bool>(() => super.hasError,
              name: '_RemoteListStore.hasError'))
          .value;
  Computed<bool> _$anyItemsLoadedComputed;

  @override
  bool get anyItemsLoaded =>
      (_$anyItemsLoadedComputed ??= Computed<bool>(() => super.anyItemsLoaded,
              name: '_RemoteListStore.anyItemsLoaded'))
          .value;

  final _$errorMessageAtom = Atom(name: '_RemoteListStore.errorMessage');

  @override
  String get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  final _$_observableLoadingFutureAtom =
      Atom(name: '_RemoteListStore._observableLoadingFuture');

  @override
  ObservableFuture<void> get _observableLoadingFuture {
    _$_observableLoadingFutureAtom.reportRead();
    return super._observableLoadingFuture;
  }

  @override
  set _observableLoadingFuture(ObservableFuture<void> value) {
    _$_observableLoadingFutureAtom
        .reportWrite(value, super._observableLoadingFuture, () {
      super._observableLoadingFuture = value;
    });
  }

  final _$loadAsyncAction = AsyncAction('_RemoteListStore.load');

  @override
  Future<void> load<T>(
      {@required Future<T> Function() get,
      @required String Function(T) use,
      @required void Function() onError}) {
    return _$loadAsyncAction
        .run(() => super.load<T>(get: get, use: use, onError: onError));
  }

  final _$_RemoteListStoreActionController =
      ActionController(name: '_RemoteListStore');

  @override
  void clear() {
    final _$actionInfo = _$_RemoteListStoreActionController.startAction(
        name: '_RemoteListStore.clear');
    try {
      return super.clear();
    } finally {
      _$_RemoteListStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
errorMessage: ${errorMessage},
isLoading: ${isLoading},
hasError: ${hasError},
anyItemsLoaded: ${anyItemsLoaded}
    ''';
  }
}

mixin _$StationStore on _StationStore, Store {
  Computed<List<Station>> _$loadedItemsComputed;

  @override
  List<Station> get loadedItems => (_$loadedItemsComputed ??=
          Computed<List<Station>>(() => super.loadedItems,
              name: '_StationStore.loadedItems'))
      .value;

  final _$sortOrderAtom = Atom(name: '_StationStore.sortOrder');

  @override
  StationSortOrder get sortOrder {
    _$sortOrderAtom.reportRead();
    return super.sortOrder;
  }

  @override
  set sortOrder(StationSortOrder value) {
    _$sortOrderAtom.reportWrite(value, super.sortOrder, () {
      super.sortOrder = value;
    });
  }

  final _$_unsortedLoadedItemsAtom =
      Atom(name: '_StationStore._unsortedLoadedItems');

  @override
  List<Station> get _unsortedLoadedItems {
    _$_unsortedLoadedItemsAtom.reportRead();
    return super._unsortedLoadedItems;
  }

  @override
  set _unsortedLoadedItems(List<Station> value) {
    _$_unsortedLoadedItemsAtom.reportWrite(value, super._unsortedLoadedItems,
        () {
      super._unsortedLoadedItems = value;
    });
  }

  @override
  String toString() {
    return '''
sortOrder: ${sortOrder},
loadedItems: ${loadedItems}
    ''';
  }
}

mixin _$CategoryStore<I extends CollectionItem, A extends Annotation>
    on _CategoryStore<I, A>, Store {
  Computed<int> _$nextPageOffsetComputed;

  @override
  int get nextPageOffset =>
      (_$nextPageOffsetComputed ??= Computed<int>(() => super.nextPageOffset,
              name: '_CategoryStore.nextPageOffset'))
          .value;

  final _$loadedItemsAtom = Atom(name: '_CategoryStore.loadedItems');

  @override
  List<CollectedItem<I, A>> get loadedItems {
    _$loadedItemsAtom.reportRead();
    return super.loadedItems;
  }

  @override
  set loadedItems(List<CollectedItem<I, A>> value) {
    _$loadedItemsAtom.reportWrite(value, super.loadedItems, () {
      super.loadedItems = value;
    });
  }

  final _$_loadedSegmentAtom = Atom(name: '_CategoryStore._loadedSegment');

  @override
  PagedCollectionSegment<I> get _loadedSegment {
    _$_loadedSegmentAtom.reportRead();
    return super._loadedSegment;
  }

  @override
  set _loadedSegment(PagedCollectionSegment<I> value) {
    _$_loadedSegmentAtom.reportWrite(value, super._loadedSegment, () {
      super._loadedSegment = value;
    });
  }

  final _$refreshAsyncAction = AsyncAction('_CategoryStore.refresh');

  @override
  Future<void> refresh() {
    return _$refreshAsyncAction.run(() => super.refresh());
  }

  @override
  String toString() {
    return '''
loadedItems: ${loadedItems},
nextPageOffset: ${nextPageOffset}
    ''';
  }
}
