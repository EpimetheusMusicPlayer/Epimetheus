import 'package:epimetheus/libepimetheus/tracks.dart';
import 'package:epimetheus/pages/collection/paged_collection_tab.dart';
import 'package:epimetheus/widgets/playable/three_line_list_tile.dart';
import 'package:epimetheus/widgets/playable/track.dart';
import 'package:flutter/material.dart';

class TracksTab extends PagedCollectionTab<Track> {
  const TracksTab() : super(buildSeparators: true);

  @override
  Widget itemListTileBuilder(
    BuildContext context,
    Track track,
    int index,
    PositionStorer storePosition,
    MenuShower showMenu,
    VoidCallback launch,
  ) {
    return InkWell(
      onTapDown: storePosition,
      onTap: launch,
      onLongPress: () => showMenu<void>(),
      child: TrackListTile(track),
    );
  }

  @override
  Widget separatorBuilder(BuildContext context, int index) => ThreeLineListTile.separator;
}
