import 'package:epimetheus/core/ui/widgets/menu_items.dart';
import 'package:epimetheus/features/collection/ui/tabs/category.dart';
import 'package:epimetheus/features/collection/ui/widgets/list_tiles/album.dart';
import 'package:epimetheus_nullable/mobx/collection/collection_store.dart';
import 'package:flutter/material.dart';
import 'package:iapetus/iapetus.dart';
import 'package:popup_menu_title/popup_menu_title.dart';

class AlbumCategoryTab extends StatelessWidget {
  final CollectionStore collectionStore;

  const AlbumCategoryTab({
    Key? key,
    required this.collectionStore,
  }) : super(key: key);

  Widget _buildAlbumTile({
    required BuildContext context,
    required int index,
    required Album item,
    required AlbumAnnotation annotation,
    required ValueChanged<Offset>? tapDownCallback,
    required ShowCategoryItemMenu? showMenu,
    required CategoryTabCollectionModifier modifyCollection,
  }) {
    return InkWell(
      onLongPress: () {
        showMenu!<Object>(
          annotation: annotation,
          context: context,
          items: [
            PopupMenuTitle(title: item.name, overflow: TextOverflow.fade),
            (item.collectedSongCount == null
                    ? CommonMenuItem.delete
                    : CommonMenuItem.addSubItems)
                .menuEntry,
            CommonMenuItem.share.menuEntry,
          ],
        );
      },
      onTapDown: (details) => tapDownCallback!(details.menuOffset),
      child: AlbumListTile(item, annotation),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CategoryTab<Album, AlbumAnnotation>(
      collectionStore: collectionStore,
      listTileBuilder: _buildAlbumTile,
      separatorBuilder: (context, index) => AlbumListTile.separator,
    );
  }
}
