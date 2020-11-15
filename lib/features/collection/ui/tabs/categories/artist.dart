import 'package:epimetheus/core/ui/widgets/menu_items.dart';
import 'package:epimetheus/features/collection/ui/tabs/category.dart';
import 'package:epimetheus/features/collection/ui/widgets/list_tiles/artist.dart';
import 'package:epimetheus_nullable/mobx/collection/collection_store.dart';
import 'package:flutter/material.dart';
import 'package:iapetus/iapetus.dart';
import 'package:popup_menu_title/popup_menu_title.dart';

class ArtistCategoryTab extends StatelessWidget {
  final CollectionStore collectionStore;

  const ArtistCategoryTab({
    Key? key,
    required this.collectionStore,
  }) : super(key: key);

  Widget _buildArtistTile({
    required BuildContext context,
    required int index,
    required Artist item,
    required ArtistAnnotation annotation,
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
            CommonMenuItem.share.menuEntry,
          ],
        );
      },
      onTapDown: (details) => tapDownCallback!(details.menuOffset),
      child: ArtistListTile(item, annotation),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CategoryTab<Artist, ArtistAnnotation>(
      collectionStore: collectionStore,
      listTileBuilder: _buildArtistTile,
      separatorBuilder: (context, index) => ArtistListTile.separator,
    );
  }
}
