import 'package:epimetheus/core/ui/widgets/menu_items.dart';
import 'package:epimetheus/features/collection/ui/tabs/category.dart';
import 'package:epimetheus/features/collection/ui/widgets/list_tiles/song.dart';
import 'package:epimetheus_nullable/mobx/collection/collection_store.dart';
import 'package:flutter/material.dart';
import 'package:iapetus/iapetus.dart';
import 'package:popup_menu_title/popup_menu_title.dart';

class SongCategoryTab extends StatelessWidget {
  final CollectionStore collectionStore;

  const SongCategoryTab({
    Key? key,
    required this.collectionStore,
  }) : super(key: key);

  Widget _buildSongTile({
    required BuildContext context,
    required int index,
    required Song item,
    required SongAnnotation annotation,
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
            CommonMenuItem.delete.menuEntry,
            CommonMenuItem.share.menuEntry,
          ],
        );
      },
      onTapDown: (details) => tapDownCallback!(details.menuOffset),
      child: SongListTile(item, annotation),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CategoryTab<Song, SongAnnotation>(
      collectionStore: collectionStore,
      listTileBuilder: _buildSongTile,
      separatorBuilder: (context, index) => SongListTile.separator,
    );
  }
}
