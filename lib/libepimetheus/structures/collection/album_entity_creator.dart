import 'package:epimetheus/libepimetheus/albums.dart';
import 'package:epimetheus/libepimetheus/structures/collection/entity_creator.dart';
import 'package:epimetheus/libepimetheus/structures/pandora_entity.dart';
import 'package:epimetheus/libepimetheus/utils.dart';

class AlbumEntityCreator extends EntityCreator<Album> {
  const AlbumEntityCreator(Map<String, dynamic> annotationsMap, List<dynamic> itemMapList) : super(annotationsMap, itemMapList);

  @override
  Album createItem(Map<String, dynamic> annotationMap, [Map<String, dynamic> itemMap]) {
    final trackCount = annotationMap['trackCount'];
    final icon = annotationMap['icon'];
    return Album(
      pandoraId: annotationMap['pandoraId'],
      name: annotationMap['name'],
      artistName: annotationMap['artistName'],
      artistId: annotationMap['artistId'],
      duration: Duration(seconds: annotationMap['duration']),
      explicitness: annotationMap['explicitness'] == 'EXPLICIT' ? PandoraEntityExplicitness.explicit : PandoraEntityExplicitness.none,
      trackCount: trackCount,
      collectedTrackCount: (itemMap ?? const {})['collectedTrackCount'] ?? trackCount,
      trackIds: [for (String trackId in annotationMap['tracks']) trackId],
      dominantColor: pandoraColorToColor(icon['dominantColor']),
      artUrls: {
        500: 'https://content-images.p-cdn.com/${icon['artUrl']}',
      },
    );
  }
}
