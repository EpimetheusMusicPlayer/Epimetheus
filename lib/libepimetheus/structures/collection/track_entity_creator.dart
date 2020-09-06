import 'package:epimetheus/libepimetheus/structures/collection/entity_creator.dart';
import 'package:epimetheus/libepimetheus/structures/pandora_entity.dart';
import 'package:epimetheus/libepimetheus/tracks.dart';
import 'package:epimetheus/libepimetheus/utils.dart';

class TrackEntityCreator extends EntityCreator<Track> {
  const TrackEntityCreator(Map<String, dynamic> annotationsMap, List<dynamic> itemMapList) : super(annotationsMap, itemMapList);

  @override
  Track createItem(Map<String, dynamic> annotationMap, [Map<String, dynamic> itemMap]) {
    final icon = annotationMap['icon'];
    return Track(
      pandoraId: annotationMap['pandoraId'],
      title: annotationMap['name'],
      trackNumber: annotationMap['trackNumber'],
      albumId: annotationMap['albumId'],
      albumTitle: annotationMap['albumName'],
      artistId: annotationMap['artistId'],
      artistTitle: annotationMap['artistName'],
      duration: Duration(seconds: annotationMap['duration']),
      explicitness: annotationMap['explicitness'] == 'EXPLICIT' ? PandoraEntityExplicitness.explicit : PandoraEntityExplicitness.none,
      dominantColor: pandoraColorToColor(icon['dominantColor']),
      artUrls: {
        500: 'https://content-images.p-cdn.com/${icon['artUrl']}',
      },
      type: PandoraEntity.types[annotationMap['type']],
    );
  }
}

class PlaylistTrackItemEntityCreator extends TrackEntityCreator {
  PlaylistTrackItemEntityCreator(Map<String, dynamic> annotationsMap, List<dynamic> itemMapList) : super(annotationsMap, itemMapList);

  @override
  String get totalCountKey => 'totalTracks';

  @override
  String getPandoraIdFromItemMap(Map<String, dynamic> itemMap) => itemMap['trackPandoraId'];
}
