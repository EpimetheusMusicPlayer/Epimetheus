import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:epimetheus/libepimetheus/networking.dart';
import 'package:epimetheus/libepimetheus/structures/collection/paged_collection_list.dart';
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
