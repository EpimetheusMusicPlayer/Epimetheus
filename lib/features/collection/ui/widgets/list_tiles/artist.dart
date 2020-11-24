import 'package:epimetheus/core/ui/widgets/three_line_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:iapetus/iapetus.dart';

class ArtistListTile extends ThreeLineListTile {
  ArtistListTile({
    bool playing = false,
    required Artist artist,
    required ArtistAnnotation annotation,
  }) : super(
          playing: playing,
          artUrl: annotation.art.recommendedUri?.toString(),
          line1: Text(
            annotation.name,
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

  static const separator = ThreeLineListTile.separator;
}
