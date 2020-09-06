import 'dart:ui';

import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:epimetheus/libepimetheus/structures/art/static_art_item.dart';
import 'package:epimetheus/libepimetheus/structures/collection/album_entity_creator.dart';
import 'package:epimetheus/libepimetheus/structures/collection/paged_collection_list.dart';
import 'package:epimetheus/libepimetheus/structures/pandora_entity.dart';
import 'package:flutter/foundation.dart';

import 'collections.dart';

class Album extends PandoraEntity with StaticArtItem {
  final Map<int, String> artUrls;
  final String name;
  final String artistName;
  final String artistId;
  final Duration duration;
  final PandoraEntityExplicitness explicitness;
  final int trackCount;
  final int collectedTrackCount;
  final List<String> trackIds;
  final Color dominantColor;

  const Album({
    @required String pandoraId,
    @required this.name,
    @required this.artistName,
    @required this.artistId,
    @required this.duration,
    @required this.explicitness,
    @required this.trackCount,
    @required this.collectedTrackCount,
    @required this.trackIds,
    @required this.dominantColor,
    @required this.artUrls,
  }) : super(pandoraId, PandoraEntityType.album);

  static PagedCollectionList<Album> _createListFromMap(Map<String, dynamic> map) {
    return PagedCollectionList<Album>.createFromMap(map, AlbumEntityCreator(map['annotations'], map['items']));
  }

  static Future<PagedCollectionList<Album>> getAlbums({
    @required User user,
    @required PagedCollectionListSortOrder sortOrder,
    @required int limit,
    @required int offset,
  }) async {
    return Album._createListFromMap(
      await getCollection(
        user: user,
        typePrefixes: const [PandoraEntityType.album],
        sortOrder: sortOrder,
        limit: limit,
        offset: offset,
      ),
    );
  }
}
