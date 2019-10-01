import 'dart:ui';

import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:epimetheus/libepimetheus/songs.dart';
import 'package:epimetheus/models/collection/collection_provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class TrackCollectionProvider extends CollectionProvider<Track> {
  TrackCollectionProvider(
    VoidCallback notifyListeners,
    BaseCacheManager cacheManager,
  ) : super(notifyListeners, cacheManager, 'There was an error fetching your songs.');

  @override
  Future<List<Track>> getData(User user) {
    return getTracks(
      user: user,
      sortOrder: TrackSortOrder.alpha,
      offset: 0,
    );
  }

  @override
  void cacheData(List<Track> tracks, BaseCacheManager cacheManager) {
    for (Track track in tracks) {
      cacheManager.downloadFile(track.getArtUrl(500));
    }
  }
}
