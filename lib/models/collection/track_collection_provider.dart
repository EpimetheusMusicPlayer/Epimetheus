import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:epimetheus/libepimetheus/songs.dart';
import 'package:epimetheus/models/collection/paged_collection_provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class TrackCollectionProvider extends PagedCollectionProvider<Track> {
  TrackCollectionProvider(
    BaseCacheManager cacheManager,
  ) : super(24, cacheManager, 'There was an error fetching your songs.');

  @override
  Future<List<Track>> getPage(User user, int offset, int pageSize) {
    return getTracks(
      user: user,
      sortOrder: TrackSortOrder.alpha,
      offset: offset,
      pageSize: pageSize,
    );
  }

  @override
  void cachePage(List<Track> tracks, BaseCacheManager cacheManager) {
    for (Track track in tracks) {
      cacheManager.downloadFile(track.getArtUrl(500));
    }
  }
}
