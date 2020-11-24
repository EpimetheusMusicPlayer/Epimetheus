import 'package:epimetheus/core/ui/widgets/three_line_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:iapetus/iapetus.dart';

class AlbumListTile extends ThreeLineMediaListTile {
  AlbumListTile({
    bool playing = false,
    required Album album,
    required AlbumAnnotation annotation,
  }) : super(
          artUrl: annotation.art.recommendedUri?.toString(),
          line1: Text(
            album.name,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          line2: Text(
            annotation.artistName,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
          line3: Text(
            'Collected ${album.collectedSongCount ?? annotation.songCount}/${annotation.songCount} tracks',
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
          duration: annotation.duration,
          isExplicit: annotation.isExplicit,
        );

  static const separator = ThreeLineListTile.separator;
}
