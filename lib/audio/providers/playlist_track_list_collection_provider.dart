import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:epimetheus/libepimetheus/playlists.dart';
import 'package:epimetheus/libepimetheus/structures/collection/paged_collection_list.dart';
import 'package:epimetheus/libepimetheus/tracks.dart';
import 'package:epimetheus/models/collection/paged_collection_provider.dart';
import 'package:flutter_cache_manager/src/cache_manager.dart';

class PlaylistTrackListCollectionProvider extends PagedCollectionProvider<Track> {
  final String pandoraId;

  int _playlistVersion = 0;

  PlaylistTrackListCollectionProvider(BaseCacheManager cacheManager, this.pandoraId) : super(cacheManager, 'playlist tracks', 100);

  /// Gets initial data containing the title, description, etc.
  /// The UI is excpected to call this once and hold on to the result -
  /// once cachedCollection has more data added to it, it looses its
  /// type along with all usefull extra data.
  Future<PlaylistTrackList> getInitialData(User user) async {
    if (cachedCollection == null)
      return cachedCollection ??= await getPage(user, 0, pageSize);
    else
      return null;
  }

  @override
  Future<PagedCollectionList<Track>> getPage(User user, int offset, int pageSize) async {
    final trackList = await Playlist.getTracksFromId(
      pandoraId: pandoraId,
      user: user,
      limit: pageSize,
      offset: offset,
      version: _playlistVersion,
    );
    _playlistVersion = trackList.version;
    return trackList;
  }

  @override
  void cachePageArt(PagedCollectionList<Track> collectionList, BaseCacheManager cacheManager) {
    collectionList.items.forEach((track) {
      cacheManager.downloadFile(track.getArtUrl(500));
    });
  }

  @override
  void clear() {
    _playlistVersion = 0;
    super.clear();
  }

  @override
  Future<void> reset(User user) {
    _playlistVersion = 0;
    return super.reset(user);
  }
}
