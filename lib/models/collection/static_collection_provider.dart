import 'dart:io';
import 'dart:ui';

import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:epimetheus/libepimetheus/exceptions.dart';
import 'package:epimetheus/libepimetheus/structures/pandora_entity.dart';
import 'package:epimetheus/models/collection/collection_provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

abstract class StaticCollectionProvider<T extends PandoraEntity> extends CollectionProvider<T> {
  List<T> _collection;

  bool _hasError = false;
  bool get hasError => _hasError;

  bool _downloading = false;

  final VoidCallback _notifyListeners;
  final BaseCacheManager _cacheManager;
  final String typeName;

  StaticCollectionProvider(this._notifyListeners, this._cacheManager, this.typeName);

  Future<List<T>> getData(User user);
  void cacheData(List<T> collection, BaseCacheManager cacheManager);

  Future<void> refresh(User user) async {
    if (!_downloading) {
      _downloading = true;

      if (_collection != null || _hasError) {
        _collection = null;
        _hasError = false;
        _notifyListeners();
      }

      void onError() {
        _hasError = true;
        _downloading = false;
        _notifyListeners();
      }

      try {
        _collection = await getData(user);
      } on SocketException {
        onError();
        return;
      } on HttpException {
        onError();
        return;
      } on PandoraException {
        onError();
        return;
      }

      cacheData(_collection, _cacheManager);

      _downloading = false;
      _notifyListeners();
    }
  }

  @override
  bool getAsync(User user) {
    if (_collection == null) {
      refresh(user);
      return false;
    } else
      return true;
  }

  List<T> getDownloaded() {
    return _collection;
  }

  @override
  void clear() {
    _hasError = false;
    _collection = null;
  }
}
