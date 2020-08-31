import 'package:epimetheus/libepimetheus/structures/art/art_item.dart';
import 'package:epimetheus/libepimetheus/structures/pandora_entity.dart';

/// This mixin defines components to deal with Thor layers, Pandora's internal dynamic album art system.
/// Many things like playlists use Thor layers to supply several album art images to be laid out in grid form.
/// Luckily for us, the final image is generated on their servers. We don't need to do anything fancy client side.
mixin ThorArtItem implements ArtItem {
  static const _fallbackUrlPrefix = r'https://web-cdn.pandora.com/web-client-assets/images/';

  static const _fallbackPaths = {
    PandoraEntityType.playlist: {
      500: 'playlist_500.eb8d7640a5e57ae3c179d39850cd4413.png',
      600: 'playlist_600.98ecca56f1b8317ee8d8748d6c98391b.png',
      640: 'playlist_640.689ee2f34cdfaad8e6021103e80eb722.png',
      1080: 'playlist_1080.e0acb9f00c765ea0b519e95325c98d19.png',
    },
    PandoraEntityType.album: {90: 'album_90.f1913cc0d8238004e6511873e5ff504a.png', 130: 'album_130.4d34ea930e8b0525994022e6f98df802.png', 500: 'album_500.7d4c7506560849c0a606b93e9f06de71.png', 600: 'album_600.6d42fe94a1769346339e836656b828e3.png', 640: 'album_640.95e90f3a2ec9c70e2b0f6b7082be38f0.png', 1080: 'album_1080.b0c4ed0405680ef66e746b279b5456aa.png'},
  };

  String get thorLayers;

  @override
  String getArtUrl(int size) {
    final sizeString = size.toString();

    if (thorLayers == null) return getFallbackUrl(PandoraEntityType.playlist, size);

    return Uri(
      scheme: 'https',
      host: 'dyn-images.p-cdn.com', // Pandora's dynamic image host, used to get Thor images
      queryParameters: {
        'l': thorLayers, // The Thor layers
        'w': sizeString, // Width
        'h': sizeString, // Height
      },
    ).toString();
  }

  String getFallbackUrl(PandoraEntityType type, int preferredSize) {
    final pathMap = _fallbackPaths[type];
    if (pathMap.containsKey(preferredSize)) return _fallbackUrlPrefix + pathMap[preferredSize];

    List<int> sortedKeys = List.from(pathMap.keys, growable: false);
    sortedKeys.sort();

    for (int size in sortedKeys) {
      if (preferredSize <= size) return _fallbackUrlPrefix + pathMap[size];
    }
    return _fallbackUrlPrefix + pathMap[sortedKeys.last];
  }
}
