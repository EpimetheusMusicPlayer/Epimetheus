import 'package:epimetheus/libepimetheus/albums.dart';
import 'package:epimetheus/libepimetheus/artists.dart';
import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:epimetheus/libepimetheus/playlists.dart';
import 'package:epimetheus/libepimetheus/songs.dart';
import 'package:epimetheus/libepimetheus/stations.dart';
import 'package:epimetheus/libepimetheus/structures/pandora_entity.dart';
import 'package:epimetheus/models/collection/collection_provider.dart';
import 'package:epimetheus/models/collection/standard_paged_collection_provider.dart';
import 'package:epimetheus/models/collection/station_collection_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:scoped_model/scoped_model.dart';

/// This [Model] holds [CollectionProvider]s.
class CollectionModel extends Model {
  /// The default page size used by paged collection providers.
  static const pageSize = 24;

  /// The cache manager used for the caching of collection art.
  final _cacheManager = DefaultCacheManager();

  /// A map mapping the collection providers to their corresponding [PandoraEntity] types.
  Map<Type, CollectionProvider<PandoraEntity>> _collectionProviders;

  /// Returns the collection provider for the passed [PandoraEntity] type.
  CollectionProvider<PandoraEntity> getCollectionProvider(Type type) => _collectionProviders[type];

  /// Asks each collection provider to pre-download some initial data.
  /// See [CollectionProvider.getAsync] for details.
  void fetchAll(User user) {
    _collectionProviders.values.forEach((provider) {
      provider.getAsync(user);
    });
  }

  /// Clears each collection provider, and notifies listeners.
  void clear() {
    _collectionProviders.values.forEach((provider) {
      provider.clear();
    });
    notifyListeners();
  }

  /// Creates a new [CollectionModel].
  CollectionModel() {
    _collectionProviders = {
      Station: StationCollectionProvider(notifyListeners, _cacheManager),
      Playlist: StandardPagedCollectionProvider<Playlist>(
        pageGetter: Playlist.getPlaylists,
        artUrlGetter: (playlist, size) => playlist.getArtUrl(size),
        cacheManager: _cacheManager,
        typeName: 'playlists',
      ),
      Artist: StandardPagedCollectionProvider<Artist>(
        pageGetter: Artist.getArtists,
        artUrlGetter: (artist, size) => artist.getArtUrl(size),
        cacheManager: _cacheManager,
        typeName: 'artists',
      ),
      Album: StandardPagedCollectionProvider<Album>(
        pageGetter: Album.getAlbums,
        artUrlGetter: (album, size) => album.getArtUrl(size),
        cacheManager: _cacheManager,
        typeName: 'albums',
      ),
      Track: StandardPagedCollectionProvider<Track>(
        pageGetter: Track.getTracks,
        artUrlGetter: (track, size) => track.getArtUrl(size),
        cacheManager: _cacheManager,
        typeName: 'tracks',
      ),
    };
  }

  /// Convenience method to find the closest [CollectionModel].
  static CollectionModel of(BuildContext context) => ScopedModel.of<CollectionModel>(context);
}
