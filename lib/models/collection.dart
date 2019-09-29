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
    _hasError = false;
    notifyListeners();
  }

  bool get hasError => _hasError;
  bool get downloading => _downloadingStations;

  Future<void> refresh(User user) async {
    await refreshStations(user);
    if (_hasError) return;
  }

  // STATIONS
  bool _downloadingStations = false;

  Future<void> refreshStations(User user) async {
    if (!_downloadingStations) {
      _downloadingStations = true;

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
      void onError() {
        _hasError = true;
        _downloadingStations = false;
        notifyListeners();
      }

      try {
        _stations = await api.getStations(user, true);
      } on SocketException {
        onError();
        return;
      } on PandoraException {
        onError();
        return;
      }

      // Cache the station art
      final cacheManager = DefaultCacheManager();
      for (api.Station station in _stations) {
        cacheManager.downloadFile(station.getArtUrl(500));
      }

      _downloadingStations = false;
      notifyListeners();
    }
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
  // END STATIONS

  static CollectionModel of(BuildContext context) => ScopedModel.of<CollectionModel>(context);
}
