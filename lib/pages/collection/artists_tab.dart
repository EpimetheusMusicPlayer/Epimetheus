import 'package:epimetheus/libepimetheus/artists.dart';
import 'package:epimetheus/pages/collection/paged_collection_tab.dart';
import 'package:epimetheus/widgets/playable/artist.dart';
import 'package:epimetheus/widgets/playable/three_line_list_tile.dart';
import 'package:flutter/material.dart';

class ArtistsTab extends PagedCollectionTab<Artist> {
  const ArtistsTab() : super(buildSeparators: true);

  @override
  Widget itemListTileBuilder(
    BuildContext context,
    Artist artist,
    int index,
    PositionStorer storePosition,
    MenuShower showMenu,
    VoidCallback launch,
  ) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed('/collection/artists/${artist.pandoraId}', arguments: artist.name);
      },
      child: ArtistListTile(artist),
    );
  }

  @override
  Widget separatorBuilder(BuildContext context, int index) => ThreeLineListTile.separator;
}
