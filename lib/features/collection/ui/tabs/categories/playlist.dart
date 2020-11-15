import 'package:epimetheus/core/ui/widgets/menu_items.dart';
import 'package:epimetheus/features/collection/ui/tabs/category.dart';
import 'package:epimetheus/features/collection/ui/utils/collection_modifications.dart';
import 'package:epimetheus/features/collection/ui/widgets/list_tiles/playlist.dart';
import 'package:epimetheus_nullable/mobx/collection/collection_store.dart';
import 'package:flutter/material.dart';
import 'package:iapetus/iapetus.dart';
import 'package:popup_menu_title/popup_menu_title.dart';

class PlaylistCategoryTab extends StatelessWidget {
  final CollectionStore collectionStore;

  const PlaylistCategoryTab({
    Key? key,
    required this.collectionStore,
  }) : super(key: key);

  Widget _buildPlaylistTile({
    required BuildContext context,
    required int index,
    required Playlist item,
    required PlaylistAnnotation annotation,
    required ValueChanged<Offset>? tapDownCallback,
    required ShowCategoryItemMenu? showMenu,
    required CategoryTabCollectionModifier modifyCollection,
  }) {
    return InkWell(
      onLongPress: () async {
        final menuResult = await showMenu!<Object>(
          annotation: annotation,
          context: context,
          items: [
            PopupMenuTitle(title: item.name, overflow: TextOverflow.fade),
            if (annotation.isEditable) CommonMenuItem.rename.menuEntry,
            CommonMenuItem.delete.menuEntry,
            CommonMenuItem.share.menuEntry,
          ],
        );

        switch (menuResult) {
          case CommonMenuItem.rename:
            handleRename(
              context: context,
              oldName: item.name,
              rename: (name) =>
                  modifyCollection((api) => annotation.rename(api, name)),
            );
            break;
        }
      },
      onTapDown: (details) => tapDownCallback!(details.menuOffset),
      child: PlaylistListTile(item, annotation),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CategoryTab<Playlist, PlaylistAnnotation>(
      collectionStore: collectionStore,
      listTileBuilder: _buildPlaylistTile,
      separatorBuilder: (context, index) => PlaylistListTile.separator,
    );
  }
}
