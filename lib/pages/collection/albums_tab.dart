import 'package:epimetheus/libepimetheus/albums.dart';
import 'package:epimetheus/pages/collection/paged_collection_tab.dart';
import 'package:epimetheus/widgets/collection/paged_collection_list_view.dart';
import 'package:epimetheus/widgets/playable/album.dart';
import 'package:epimetheus/widgets/playable/three_line_list_tile.dart';
import 'package:flutter/material.dart';

class AlbumsTab extends PagedCollectionTab<Album> {
  const AlbumsTab() : super(buildSeparators: true);

  @override
  Widget itemListTileBuilder(
    BuildContext context,
    Album album,
    int index,
    PositionStorer storePosition,
    MenuShower showMenu,
    VoidCallback launch,
  ) {
    return InkWell(
      onTapDown: storePosition,
      onTap: launch,
      onLongPress: () => showMenu<void>(
        standardMenuItems: {
          if (album.trackCount == album.collectedTrackCount) StandardPopupMenuItem.delete: 'Remove' else StandardPopupMenuItem.add: 'Add all tracks',
        },
      ),
      child: AlbumListTile(album),
    );
  }

  @override
  Widget separatorBuilder(BuildContext context, int index) => ThreeLineListTile.separator;
}
