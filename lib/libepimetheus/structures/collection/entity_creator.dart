import 'package:epimetheus/libepimetheus/structures/collection/album_entity_creator.dart';
import 'package:epimetheus/libepimetheus/structures/collection/artist_entity_creator.dart';
import 'package:epimetheus/libepimetheus/structures/collection/playlist_entity_creator.dart';
import 'package:epimetheus/libepimetheus/structures/collection/track_entity_creator.dart';
import 'package:epimetheus/libepimetheus/structures/pandora_entity.dart';

final genericEntityCreators = EntityCreator._generateGenericCreators();

abstract class EntityCreator<T extends PandoraEntity> {
  final Map<String, dynamic> annotationsMap;
  final List<dynamic> itemMapList;

  const EntityCreator(this.annotationsMap, this.itemMapList);

  String getPandoraIdFromItemMap(Map<String, dynamic> itemMap) {
    return itemMap['pandoraId'];
  }

  String get totalCountKey => 'totalCount';

  /// Create the item. Note: the item list and annotations map may be null when
  /// this is called.
  T createItem(Map<String, dynamic> annotationMap, [Map<String, dynamic> itemMap]);

  List<T> createItemList() {
    return itemMapList == null
        ? []
        : List<T>.generate(
            itemMapList.length,
            (index) {
              final itemMap = itemMapList[index];
              return createItem(annotationsMap[getPandoraIdFromItemMap(itemMap)], itemMap);
            },
          )
      ..removeWhere((item) => item == null);
  }

  List<PandoraEntity> createRelatedItemList(List<T> items) {
    final relatedItems = <PandoraEntity>[];
    final itemPandoraIds = items.map((item) => item.pandoraId);
    annotationsMap?.forEach((String pandoraId, annotationMap) {
      if (!itemPandoraIds.contains(pandoraId)) {
        final relatedItem = genericEntityCreators[PandoraEntity.types[annotationMap['type']]]?.createItem(annotationMap);
        if (relatedItem != null) ;
        relatedItems.add(relatedItem);
      }
    });
    return relatedItems;
  }

  static EntityCreator createDynamicEntityCreator(Map<String, dynamic> annotationMap, PandoraEntityType type, [List<Map<String, dynamic>> itemMapList]) {
    switch (type) {
      case PandoraEntityType.track:
        return TrackEntityCreator(annotationMap, itemMapList);
      case PandoraEntityType.playlist:
        return PlaylistEntityCreator(annotationMap, itemMapList);
      case PandoraEntityType.artist:
        return ArtistEntityCreator(annotationMap, itemMapList);
      case PandoraEntityType.album:
        return AlbumEntityCreator(annotationMap, itemMapList);
      default:
        return null;
    }
  }

  static Map<PandoraEntityType, EntityCreator> _generateGenericCreators() {
    final creators = <PandoraEntityType, EntityCreator>{};
    for (final type in PandoraEntityType.values) {
      creators[type] = createDynamicEntityCreator(null, type);
    }
    return creators;
  }
}
