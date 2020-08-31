import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:epimetheus/libepimetheus/collections.dart';
import 'package:epimetheus/libepimetheus/networking.dart';
import 'package:epimetheus/libepimetheus/structures/art/static_art_item.dart';
import 'package:epimetheus/libepimetheus/structures/paged_collection_list.dart';
import 'package:epimetheus/libepimetheus/structures/pandora_entity.dart';
import 'package:epimetheus/libepimetheus/utils.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

class Artist extends PandoraEntity with StaticArtItem {
  final Map<int, String> artUrls;
  final String name;
  final int albumCount;
  final int trackCount;
  final bool hasRadio;
  final Color dominantColor;

  const Artist._internal({
    @required String pandoraId,
    @required this.name,
    @required this.albumCount,
    @required this.trackCount,
    @required this.hasRadio,
    @required this.dominantColor,
    @required this.artUrls,
  }) : super(pandoraId, PandoraEntityType.artist);

  static Artist createFromMaps(Map<String, dynamic> annotation, [Map<String, dynamic> collectionDetails]) {
    final icon = annotation['icon'];
    return Artist._internal(
      pandoraId: annotation['pandoraId'],
      name: annotation['name'],
      albumCount: annotation['albumCount'],
      trackCount: annotation['trackCount'],
      hasRadio: annotation['hasRadio'],
      dominantColor: pandoraColorToColor(icon['dominantColor']),
      artUrls: {
        500: 'https://content-images.p-cdn.com/${icon['artUrl']}',
      },
    );
  }

  static PagedCollectionList<Artist> _createListFromMap(Map<String, dynamic> map) {
    return PagedCollectionList<Artist>.createFromMap(map, createFromMaps, createDynamicEntityFromMaps);
  }

  static Future<PagedCollectionList<Artist>> getArtists({
    @required User user,
    @required PagedCollectionListSortOrder sortOrder,
    @required int limit,
    @required int offset,
  }) async {
    return Artist._createListFromMap(
      await getCollection(
        user: user,
        typePrefixes: const [PandoraEntityType.artist],
        sortOrder: sortOrder,
        limit: limit,
        offset: offset,
      ),
    );
  }

  static Future<PagedCollectionList<PandoraEntity>> getCollectedItemsFromId({
    @required String pandoraId,
    @required User user,
    @required int limit,
    @required int offset,
  }) async {
    return PagedCollectionList<PandoraEntity>.createFromMap(
      await makeApiRequest(
        version: 'v5',
        endpoint: 'collections/getItemsByArtist',
        requestData: {
          'request': {
            'artistPandoraId': pandoraId,
            'offset': offset,
            'limit': limit,
            'annotationLimit': limit,
          },
        },
        user: user,
      ),
      createDynamicEntityFromMaps,
      createDynamicEntityFromMaps,
    );
  }

  Future<PagedCollectionList<PandoraEntity>> getCollectedItems({
    @required User user,
    @required PagedCollectionListSortOrder sortOrder,
    @required int limit,
    @required int offset,
  }) =>
      getCollectedItemsFromId(
        pandoraId: pandoraId,
        user: user,
        limit: limit,
        offset: offset,
      );
}
