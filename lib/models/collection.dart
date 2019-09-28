import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:epimetheus/libepimetheus/stations.dart' as api;
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:scoped_model/scoped_model.dart';

class CollectionModel extends Model {
  List<api.Station> _stations;

  void clear() {
    _stations = null;
    notifyListeners();
  }

  Future<void> refreshStations(User user) async {
    // Download the stations list
    _stations = await api.getStations(user, true);

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

  static CollectionModel of(BuildContext context) => ScopedModel.of<CollectionModel>(context);
}
