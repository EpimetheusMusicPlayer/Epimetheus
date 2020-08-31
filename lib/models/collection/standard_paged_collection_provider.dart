import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:epimetheus/libepimetheus/structures/paged_collection_list.dart';
import 'package:epimetheus/libepimetheus/structures/pandora_entity.dart';
import 'package:epimetheus/models/collection/collection_model.dart';
import 'package:epimetheus/models/collection/paged_collection_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

typedef ArtUrlGetter<T> = String Function(T item, int preferedSize);

/// This class is essentially a shim between the Pandora API library and the base [PagedCollectionProvider].
///
/// This is a [PagedCollectionProvider] that can be passed a [pageGetter] method conforming
/// to the [PagedCollectionListGetter] typedef, and an [artUrlGetter] method conforming to the
/// [ArtUrlGetter] typedef.
///
/// As most of the Pandora API library's collection and art methods conform to (or can be easily
/// adapted to) these typedefs, this class allows the easy creation of [PagedCollectionProvider]
/// instances to handle many different [PandoraEntity] types.
class StandardPagedCollectionProvider<T extends PandoraEntity> extends PagedCollectionProvider<T> {
  final PagedCollectionListGetter<T> pageGetter;
  final ArtUrlGetter<T> artUrlGetter;

  StandardPagedCollectionProvider({
    @required this.pageGetter,
    @required this.artUrlGetter,
    @required BaseCacheManager cacheManager,
    @required String typeName,
    int pageSize = CollectionModel.pageSize,
  }) : super(cacheManager, typeName, pageSize);

  @override
  Future<PagedCollectionList<T>> getPage(User user, int offset, int pageSize) => pageGetter(
        user: user,
        sortOrder: PagedCollectionListSortOrder.alpha,
        limit: pageSize,
        offset: offset,
      );

  @override
  void cachePageArt(PagedCollectionList<T> collectionList, BaseCacheManager cacheManager) {
    collectionList.items.forEach((item) {
      cacheManager.downloadFile(artUrlGetter(item, 500));
    });
  }
}
