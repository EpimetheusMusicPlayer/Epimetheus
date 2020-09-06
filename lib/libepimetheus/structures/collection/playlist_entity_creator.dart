import 'package:epimetheus/libepimetheus/playlists.dart';
import 'package:epimetheus/libepimetheus/structures/collection/entity_creator.dart';

class PlaylistEntityCreator extends EntityCreator<Playlist> {
  const PlaylistEntityCreator(Map<String, dynamic> annotationsMap, List<dynamic> itemMapList) : super(annotationsMap, itemMapList);

  @override
  Playlist createItem(Map<String, dynamic> annotationMap, [Map<String, dynamic> itemMap]) {
    return Playlist(
      pandoraId: annotationMap['pandoraId'],
      thorLayers: annotationMap['thorLayers'],
      name: annotationMap['name'],
      duration: Duration(seconds: annotationMap['duration']),
      description: annotationMap['description'],
      addedTime: annotationMap['timeCreated'],
      updatedTime: annotationMap['timeLastUpdated'],
      editable: annotationMap['editable'],
    );
  }
}
