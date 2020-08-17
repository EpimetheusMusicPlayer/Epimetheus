import 'dart:io';

import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:epimetheus/libepimetheus/exceptions.dart';
import 'package:flutter_cache_manager/src/cache_manager.dart';

abstract class PagedCollectionProvider<T> {
  PagedCollectionProvider(this.pageSize, this._cacheManager, this.errorMessage);

  List<T> _collection = <T>[];
  List<T> get collection => _collection;

  bool _hasError = false;

  bool get hasError => _hasError;

  final int pageSize;
  final BaseCacheManager _cacheManager;
  final String errorMessage;

  Future<List<T>> getPage(
    User user,
    int offset,
    int pageSize,
  );

  void cachePage(List<T> collection, BaseCacheManager cacheManager);

  Future<List<T>> newPage(User user, int index) async {
    if (_hasError) {
      _hasError = false;
    }

    onError(Exception e) {
      _hasError = true;
    }

    try {
      List<T> newPage = await getPage(user, index, pageSize);
      _collection += newPage;
      cachePage(newPage, _cacheManager);

      return newPage;
    } on SocketException catch (e) {
      onError(e);
      return null;
    } on PandoraException catch (e) {
      onError(e);
      return null;
    }
  }

  List<T> getAsync(User user) {
    if (_collection.isEmpty) newPage(user, 0);
    return _collection;
  }

  void clear() {
    _collection.clear();
    _hasError = false;
  }
}
