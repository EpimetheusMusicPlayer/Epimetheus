import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:epimetheus/libepimetheus/structures/collection/entity_creator.dart';
import 'package:epimetheus/libepimetheus/structures/pandora_entity.dart';

/// Methods that return a [PagedCollectionList] should try to conform to this method signature.
typedef PagedCollectionListGetter<T extends PandoraEntity> = Future<PagedCollectionList<T>> Function({
  User user,
  PagedCollectionListSortOrder sortOrder,
  int limit,
  int offset,
});

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

class ListenerIdInfo {
  final int id;
  final String pandoraId;
  final String token;

  ListenerIdInfo._internal({
    this.id,
    this.pandoraId,
    this.token,
  });

  static ListenerIdInfo _createFromMap(dynamic map) {
    return ListenerIdInfo._internal(
      id: map['listenerId'],
      pandoraId: map['listenerPandoraId'],
      token: map['listenerIdToken'],
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ListenerIdInfo && other.token == token && other.id == id;
  }
}

class PagedCollectionList<T extends PandoraEntity> {
  final PandoraEntityType type;
  final ListenerIdInfo listenerIdInfo;
  final int offset;
  final int limit;
  final int totalCount;
  final List<T> items;
  final List<PandoraEntity> relatedItems;
  Map<String, dynamic> other;

  PagedCollectionList({
    this.type,
    this.listenerIdInfo,
    this.offset,
    this.limit,
    this.totalCount,
    this.items,
    this.relatedItems,
  });

  /// [map] is the decoded JSON response from a Pandora collection API, [creator] is used to create the collected items, and [dynamicCreator]
  /// creates related items (that are included in the annotation list but not in the collected item list) that can be of any type.
  factory PagedCollectionList.createFromMap(
    Map<String, dynamic> map,
    EntityCreator<T> creator,
  ) {
    final List<T> items = creator.createItemList();
    final relatedItems = creator.createRelatedItemList(items);

    return PagedCollectionList(
      type: PandoraEntity.types[map['view']],
      listenerIdInfo: ListenerIdInfo._createFromMap(map),
      offset: map['offset'],
      limit: map['limit'],
      totalCount: map[creator.totalCountKey],
      items: items,
      relatedItems: relatedItems,
      // other,
    );
  }

  PagedCollectionList<T> sublist(int start, int end) {
    return PagedCollectionList<T>(
      type: type,
      listenerIdInfo: listenerIdInfo,
      offset: start,
      limit: end - start,
      totalCount: totalCount,
      items: items.sublist(start, end),
      relatedItems: relatedItems,
    );
  }

  PagedCollectionList<T> operator +(PagedCollectionList<T> newList) {
    if (type != newList.type) {
      throw PagedCollectionListException(PagedCollectionListExceptionReason.typeMismatch);
    }

    if (listenerIdInfo != newList.listenerIdInfo) {
      throw PagedCollectionListException(PagedCollectionListExceptionReason.listenerPandoraIdMismatch);
    }

    if (offset != null && offset != newList.offset - newList.limit) {
      throw PagedCollectionListException(PagedCollectionListExceptionReason.offsetMismatch);
    }

    if (totalCount != newList.totalCount) {
      throw PagedCollectionListException(PagedCollectionListExceptionReason.totalCountMismatch);
    }

    return PagedCollectionList<T>(
      type: type,
      listenerIdInfo: listenerIdInfo,
      offset: newList.offset,
      limit: newList.limit,
      totalCount: totalCount,
      items: items + newList.items,
      relatedItems: relatedItems,
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
