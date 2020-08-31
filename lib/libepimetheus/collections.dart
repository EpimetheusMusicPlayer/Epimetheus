import 'package:epimetheus/api.dart';
import 'package:epimetheus/libepimetheus/albums.dart';
import 'package:epimetheus/libepimetheus/artists.dart';
import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:epimetheus/libepimetheus/networking.dart';
import 'package:epimetheus/libepimetheus/playlists.dart';
import 'package:epimetheus/libepimetheus/songs.dart';
import 'package:epimetheus/libepimetheus/structures/paged_collection_list.dart';
import 'package:epimetheus/libepimetheus/structures/pandora_entity.dart';
import 'package:flutter/foundation.dart';

/// Most collections (with the exception of playlists and stations) will use this one API endpoint.
Future<Map<String, dynamic>> getCollection({
  @required User user,
  @required List<PandoraEntityType> typePrefixes,
  @required PagedCollectionListSortOrder sortOrder,
  @required int limit,
  @required int offset,
}) {
  return makeApiRequest(
    version: 'v6',
    endpoint: 'collections/getSortedByTypes',
    requestData: {
      'request': {
        'sortOrder': PagedCollectionList.sortOrderNames[sortOrder],
        'offset': offset,
        'limit': limit,
        'annotationLimit': limit,
        'typePrefixes': [for (final type in typePrefixes) PandoraEntity.typeNames[type]],
      },
    },
    user: user,
  );
}

/// This [EntityCreator] uses the right type-specific creator when given a [PandoraEntity] that may be any type.
PandoraEntity createDynamicEntityFromMaps(Map<String, dynamic> annotation, [Map<String, dynamic> collectionDetails]) {
  switch (PandoraEntity.types[annotation['type']]) {
    case PandoraEntityType.track:
      return Track.createFromMaps(annotation, collectionDetails);
    case PandoraEntityType.playlist:
      return Playlist.createFromMaps(annotation, collectionDetails);
    case PandoraEntityType.artist:
      return Artist.createFromMaps(annotation, collectionDetails);
    case PandoraEntityType.album:
      return Album.createFromMaps(annotation, collectionDetails);
    default:
      return null;
  }
}

extension PandoraEntityExtensions on PandoraEntity {
  Future<bool> remove(User user) async {
    final response = await makeCaughtApiRequest(
      version: 'v6',
      endpoint: 'collections/removeItem',
      requestData: {
        'request': {
          'pandoraId': pandoraId,
        },
      },
      user: user,
    );

    if (response == null || response['removed'] == null) return false;

    return response['removed'][0]['pandoraId'] == pandoraId;
  }

  Future<bool> add(User user) async {
    final response = await makeCaughtApiRequest(
      version: 'v6',
      endpoint: 'collections/addItem',
      requestData: {
        'request': {
          'pandoraId': pandoraId,
        },
      },
      user: user,
    );

    if (response == null || response['added'] == null) return false;

    return response['added'][0]['pandoraId'] == pandoraId;
  }
}
