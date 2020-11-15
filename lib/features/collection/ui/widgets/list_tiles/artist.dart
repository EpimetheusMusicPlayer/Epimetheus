import 'package:epimetheus/core/ui/widgets/playable.dart';
import 'package:epimetheus/features/collection/ui/widgets/list_tiles/three_line_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:iapetus/iapetus.dart';

class ArtistListTile extends Playable<Artist> {
  final ArtistAnnotation annotation;

  ArtistListTile(Artist item, this.annotation) : super(item);

  @override
  Widget build(BuildContext context) {
    return ThreeLineListTile(
      artUrl: annotation.art.recommendedUri?.toString(),
      line1: Text(
        item.name,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      line2: Text(
        '${annotation.albumCount} album${annotation.albumCount == 1 ? '' : 's'}',
        softWrap: false,
        overflow: TextOverflow.ellipsis,
      ),
      line3: Text(
        '${annotation.songCount} track${annotation.songCount == 1 ? '' : 's'}',
        softWrap: false,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  static const separator = ThreeLineListTile.separator;
}
