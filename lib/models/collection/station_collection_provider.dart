import 'dart:ui';

import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:epimetheus/libepimetheus/stations.dart';
import 'package:epimetheus/models/collection/collection_provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class StationCollectionProvider extends CollectionProvider<Station> {
  StationCollectionProvider(
    VoidCallback notifyListeners,
    BaseCacheManager cacheManager,
  ) : super(notifyListeners, cacheManager, 'There was an error fetching your stations.');

  @override
  Future<List<Station>> getData(User user) => getStations(user, true);

  @override
  void cacheData(List<Station> stations, BaseCacheManager cacheManager) {
    for (Station station in stations) {
      cacheManager.downloadFile(station.getArtUrl(500));
    }
  }
}
