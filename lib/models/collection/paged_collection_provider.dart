import 'dart:io';

import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:epimetheus/libepimetheus/exceptions.dart';
import 'package:epimetheus/libepimetheus/structures/paged_collection_list.dart';
import 'package:epimetheus/libepimetheus/structures/pandora_entity.dart';
import 'package:epimetheus/models/collection/collection_model.dart';
import 'package:epimetheus/models/collection/collection_provider.dart';
import 'package:flutter_cache_manager/src/cache_manager.dart';

abstract class PagedCollectionProvider<T extends PandoraEntity> extends CollectionProvider<T> {
  final int pageSize;
  final BaseCacheManager _cacheManager;
  final String typeName;

  PagedCollectionProvider(this._cacheManager, this.typeName, [this.pageSize = CollectionModel.pageSize]);

  /// Must return a [PagedCollectionList] with the specified offset and pageSize.
  Future<PagedCollectionList<T>> getPage(
    User user,
    int offset,
    int pageSize,
  );

  /// Cache the collection's item art.
  void cachePageArt(PagedCollectionList<T> collection, BaseCacheManager cacheManager);

  /// Holds a merged collection containing all the downloaded pages
  PagedCollectionList<T> _cachedCollection;

  PagedCollectionList<T> get collection => _cachedCollection;

  /// Holds the error state
  bool _hasError = false;

  bool get hasError => _hasError;

  /// Holds any futures pending (such as network requests to delete an item).
  /// When getting a new page, any futures in this list are waited on first.
  List<Future<dynamic>> _pendingFutures = [];

  /// Add a pending future to [_pendingFutures].
  Future<T> addPendingFuture<T>(Future<T> pendingFuture) {
    _pendingFutures.add(pendingFuture
      ..then((_) {
        _pendingFutures.remove(pendingFuture);
      }));
    return pendingFuture;
  }

  /// This method is used to download and cache a new page. It should not be overridden;
  /// it uses downloading logic from [getPage], which should be overridden instead.
  Future<PagedCollectionList<T>> newPage(User user, int index) async {
    // Reset the error state.
    if (_hasError) {
      _hasError = false;
    }

    // Deal with errors here.
    onError(Exception e) {
      _hasError = true;
    }

    try {
      await Future.wait(_pendingFutures);
      if (_cachedCollection == null) {
        // If the cached collection is null, grab the first page.
        if (index == 0) {
          _cachedCollection = await getPage(user, index, pageSize);
        } else {
          // If the cached collection is null, no page other than the first should ever be requested.
          // If this has happened, something's terribly wrong.
          throw PagedCollectionListException(PagedCollectionListExceptionReason.offsetMismatch);
        }
      } else {
        // Check if the page at the requested index is already cached.
        // If the page is not the last, the number of cached items will be more than or equal to
        // the index + the page size if that page is cached.
        // If the page is the last, it will be equal to the total item count.
        //
        // If the page is not already cached, download it.
        final needsLastPage = _cachedCollection.totalCount - index < pageSize;
        if (_cachedCollection.items.length < (needsLastPage ? _cachedCollection.totalCount : index + pageSize)) {
          // Download the new page (since it is not already cached)
          final newPage = await getPage(user, index, pageSize);

          // Add the new page to the merged collection
          _cachedCollection += newPage;

          // Cache the new page's art.
          cachePageArt(newPage, _cacheManager);
        }
      }

      // Sublist and return the requested page from the merged collection (at this point, it should always be cached).
      final pageEndOffset = index + pageSize;
      final sublistEnd = _cachedCollection.totalCount < pageEndOffset ? _cachedCollection.totalCount : pageEndOffset;
      return _cachedCollection.sublist(index, sublistEnd);
    } on SocketException catch (e) {
      // Catch network errors
      onError(e);
      return null;
    } on PandoraException catch (e) {
      // Catch API errors
      onError(e);
      return null;
    }
  }

  Future<void> reset(User user) async {
    onError(Exception e) {
      _cachedCollection = null;
      _hasError = true;
    }

    try {
      final newPage = await getPage(user, 0, pageSize);
      _cachedCollection = newPage;
      _hasError = false;
    } on SocketException catch (e) {
      // Catch network errors
      onError(e);
    } on PandoraException catch (e) {
      // Catch API errors
      onError(e);
    }
  }

  @override
  bool getAsync(User user) {
    if (_cachedCollection == null) {
      addPendingFuture(newPage(user, 0));
      return false;
    } else
      return true;
  }

  @override
  void clear() {
    _cachedCollection = null;
    _hasError = false;
  }
}
