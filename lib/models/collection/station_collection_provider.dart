import 'dart:io';
import 'dart:ui';

import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:epimetheus/libepimetheus/stations.dart';
import 'package:epimetheus/models/collection/static_collection_provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class StationCollectionProvider extends StaticCollectionProvider<Station> {
  StationCollectionProvider(
    VoidCallback notifyListeners,
    BaseCacheManager cacheManager,
  ) : super(notifyListeners, cacheManager, 'stations');

  @override
  Future<List<Station>> getData(User user) async {
    final stations = await Station.getStations(user, true);

    stations.sort((s1, s2) {
      if (s1.isShuffle) return -2;
      if (s2.isShuffle) return 2;
      if (s1.isThumbprint) return -1;
      if (s2.isThumbprint) return 1;

      return s1.title.compareTo(s2.title);
    });

    return stations;
  }

  @override
  void cacheData(List<Station> stations, BaseCacheManager cacheManager) {
    for (Station station in stations) {
      cacheManager
          .downloadFile(
            station.getArtUrl(500),
          )
          .catchError(
            (error) {},
            test: (error) => error is HttpException || error is SocketException,
          );
    }
  }
}
