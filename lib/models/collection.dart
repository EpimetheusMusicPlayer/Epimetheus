import 'dart:io';

import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:epimetheus/libepimetheus/exceptions.dart';
import 'package:epimetheus/libepimetheus/stations.dart' as api;
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:scoped_model/scoped_model.dart';

class CollectionModel extends Model {
  List<api.Station> _stations;
  bool _hasError = false;

  void clear() {
    _stations = null;
    notifyListeners();
  }

  bool get hasError => _hasError;

  Future<void> refreshStations(User user) async {
    if (_stations != null || _hasError) {
      if (_stations != null) {
        _stations = null;
      }
      if (_hasError) {
        _hasError = false;
      }

      notifyListeners();
    }

    // Download the stations list
    try {
      _stations = await api.getStations(user, true);
    } on SocketException {
      _hasError = true;
      notifyListeners();
      return;
    } on PandoraException {
      _hasError = true;
      notifyListeners();
      return;
    }

    // Cache the station art
    final cacheManager = DefaultCacheManager();
    for (api.Station station in _stations) {
      cacheManager.downloadFile(station.getArtUrl(500));
    }

    notifyListeners();
  }

  Future<List<api.Station>> getStations(User user) async {
    if (_stations == null) {
      await refreshStations(user);
    }
    return _stations;
  }

  List<api.Station> asyncStations(User user) {
    if (_stations == null) refreshStations(user);
    return _stations;
  }

  static CollectionModel of(BuildContext context) => ScopedModel.of<CollectionModel>(context);
}
