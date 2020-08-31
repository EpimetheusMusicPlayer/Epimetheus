import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:epimetheus/libepimetheus/collections.dart';
import 'package:epimetheus/libepimetheus/networking.dart';
import 'package:epimetheus/libepimetheus/structures/art/thor_art_item.dart';
import 'package:epimetheus/libepimetheus/structures/paged_collection_list.dart';
import 'package:epimetheus/libepimetheus/structures/pandora_entity.dart';
import 'package:flutter/foundation.dart';

class Playlist extends PandoraEntity with ThorArtItem {
  final String thorLayers;
  final String name;
  final String description;
  final Duration duration;
  final int addedTime;
  final int updatedTime;
  final bool editable;

  Playlist._internal({
    @required String pandoraId,
    @required this.thorLayers,
    @required this.name,
    @required this.description,
    @required this.duration,
    @required this.addedTime,
    @required this.updatedTime,
    @required this.editable,
  }) : super(pandoraId, PandoraEntityType.playlist);

  static Playlist createFromMaps(Map<String, dynamic> annotation, [Map<String, dynamic> collectionDetails]) {
    return Playlist._internal(
      pandoraId: annotation['pandoraId'],
      thorLayers: annotation['thorLayers'],
      name: annotation['name'],
      duration: Duration(seconds: annotation['duration']),
      description: annotation['description'],
      addedTime: annotation['timeCreated'],
      updatedTime: annotation['timeLastUpdated'],
      editable: annotation['editable'],
    );
  }

  static PagedCollectionList<Playlist> _createListFromMap(Map<String, dynamic> map) {
    return PagedCollectionList<Playlist>.createFromMap(map, createFromMaps, createDynamicEntityFromMaps);
  }

  static Future<PagedCollectionList<Playlist>> getPlaylists({
    @required User user,
    @required PagedCollectionListSortOrder sortOrder,
    @required int limit,
    @required int offset,
  }) async {
    return Playlist._createListFromMap(
      await makeApiRequest(
        version: 'v6',
        endpoint: 'collections/getSortedPlaylists',
        requestData: {
          'allowedTypes': [
            'TR',
            'AM',
          ],
          'isRecentModifiedPlaylists': false,
          'request': {
            'annotationLimit': limit,
            'limit': limit,
            'offset': offset,
            'sortOrder': PagedCollectionList.sortOrderNames[sortOrder],
          },
        },
        user: user,
      ),
    );
  }
}
