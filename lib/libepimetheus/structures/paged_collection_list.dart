import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:epimetheus/libepimetheus/structures/pandora_entity.dart';

/// Methods that return a [PagedCollectionList] should try to conform to this method signature.
typedef PagedCollectionListGetter<T extends PandoraEntity> = Future<PagedCollectionList<T>> Function({
  User user,
  PagedCollectionListSortOrder sortOrder,
  int limit,
  int offset,
});

/// [annotation] is the item annotation, which contains details about the item common to all users. [collectionItem], if provided,
/// contains details specific to the status in the user's collection.
typedef EntityCreator<T extends PandoraEntity> = T Function(Map<String, dynamic> annotation, [Map<String, dynamic> collectionDetails]);

enum PagedCollectionListExceptionReason {
  typeMismatch,
  listenerPandoraIdMismatch,
  offsetMismatch,
  totalCountMismatch,
}

class PagedCollectionListException implements Exception {
  final PagedCollectionListExceptionReason reason;

  PagedCollectionListException(this.reason);
}

enum PagedCollectionListSortOrder {
  alpha, //                 ALPHA
  mostRecentModified, //    MOST_RECENT_MODIFIED
}

class PagedCollectionList<T extends PandoraEntity> {
  final PandoraEntityType type;
  final String listenerPandoraId;
  final int offset;
  final int limit;
  final int totalCount;
  final List<T> items;
  final List<PandoraEntity> relatedItems;

  PagedCollectionList._internal(
    this.type,
    this.listenerPandoraId,
    this.offset,
    this.limit,
    this.totalCount,
    this.items,
    this.relatedItems,
  );

  /// [map] is the decoded JSON response from a Pandora collection API, [creator] is used to create the collected items, and [dynamicCreator]
  /// creates related items (that are included in the annotation list but not in the collected item list) that can be of any type.
  factory PagedCollectionList.createFromMap(Map<String, dynamic> map, EntityCreator<T> creator, EntityCreator<PandoraEntity> dynamicCreator) {
    final List<dynamic> itemList = map['items'];
    final dynamic annotationMap = map['annotations'];

    final List<T> items = itemList == null
        ? const []
        : List<T>.generate(
            itemList.length,
            (index) {
              final itemMap = itemList[index];
              return creator(annotationMap[itemMap['pandoraId']], itemMap);
            },
          )
      ..removeWhere((item) => item == null);

    final relatedItems = <PandoraEntity>[];
    final itemPandoraIds = items.map((item) => item.pandoraId);
    annotationMap.forEach((String pandoraId, annotation) {
      if (!itemPandoraIds.contains(pandoraId)) relatedItems.add(dynamicCreator(annotation));
    });

    return PagedCollectionList._internal(
      PandoraEntity.types[map['view']],
      map['listenerPandoraId'],
      map['offset'],
      map['limit'],
      map['totalCount'],
      items,
      relatedItems,
    );
  }

  PagedCollectionList<T> sublist(int start, int end) {
    return PagedCollectionList<T>._internal(
      type,
      listenerPandoraId,
      start,
      end - start,
      totalCount,
      items.sublist(start, end),
      relatedItems,
    );
  }

  PagedCollectionList<T> operator +(PagedCollectionList<T> newList) {
    if (type != newList.type) {
      throw PagedCollectionListException(PagedCollectionListExceptionReason.typeMismatch);
    }

    if (listenerPandoraId != newList.listenerPandoraId) {
      throw PagedCollectionListException(PagedCollectionListExceptionReason.listenerPandoraIdMismatch);
    }

    if (offset != newList.offset - newList.limit) {
      throw PagedCollectionListException(PagedCollectionListExceptionReason.offsetMismatch);
    }

    if (totalCount != newList.totalCount) {
      throw PagedCollectionListException(PagedCollectionListExceptionReason.totalCountMismatch);
    }

    return PagedCollectionList<T>._internal(
      type,
      listenerPandoraId,
      newList.offset,
      newList.limit,
      totalCount,
      items + newList.items,
      relatedItems,
    );
  }

  static int pageNumberToIndex(int pageNumber, int pageSize) => (pageNumber - 1) * pageSize;

  static const Map<String, PagedCollectionListSortOrder> sortOrders = {
    'ALPHA': PagedCollectionListSortOrder.alpha,
    'MOST_RECENT_MODIFIED': PagedCollectionListSortOrder.mostRecentModified,
  };

  static const Map<PagedCollectionListSortOrder, String> sortOrderNames = {
    PagedCollectionListSortOrder.alpha: 'ALPHA',
    PagedCollectionListSortOrder.mostRecentModified: 'MOST_RECENT_MODIFIED',
  };
}
