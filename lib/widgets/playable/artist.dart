import 'package:epimetheus/libepimetheus/artists.dart';
import 'package:epimetheus/widgets/playable/playable.dart';
import 'package:epimetheus/widgets/playable/three_line_list_tile.dart';
import 'package:flutter/material.dart';

class ArtistListTile extends PlayableWidget<Artist> {
  ArtistListTile(Artist item) : super(item);

  @override
  Widget build(BuildContext context) {
    return ThreeLineListTile(
      artUrl: item.getArtUrl(500),
      line1: Text(
        item.name,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      line2: Text(
        '${item.albumCount} album${item.albumCount == 1 ? '' : 's'}',
        softWrap: false,
        overflow: TextOverflow.ellipsis,
      ),
      line3: Text(
        '${item.trackCount} track${item.trackCount == 1 ? '' : 's'}',
        softWrap: false,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
