import 'package:epimetheus/libepimetheus/playlists.dart';
import 'package:epimetheus/pages/collection/paged_collection_tab.dart';
import 'package:epimetheus/widgets/playable/playlist.dart';
import 'package:flutter/material.dart';

class PlaylistsTab extends PagedCollectionTab<Playlist> {
  const PlaylistsTab() : super(buildSeparators: true);

  @override
  Widget itemListTileBuilder(BuildContext context, Playlist playlist, int index, PositionStorer storePosition, MenuShower showMenu) {
    return PlaylistListTile(playlist);
  }

  @override
  Widget separatorBuilder(BuildContext context, int index) => const SizedBox();
}
