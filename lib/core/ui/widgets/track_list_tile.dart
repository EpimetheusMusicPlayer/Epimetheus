import 'package:epimetheus/core/ui/widgets/three_line_list_tile.dart';
import 'package:flutter/material.dart';

/// A generic [ThreeLineMediaListTile] wrapper that displays song data.
class TrackListTile extends ThreeLineMediaListTile {
  TrackListTile({
    bool playing = false,
    required String name,
    required String artistName,
    required String albumName,
    required Duration duration,
    required bool isExplicit,
    required String? artUrl,
    VoidCallback? onPlayPress,
  }) : super(
          playing: playing,
          artUrl: artUrl,
          line1: Text(
            name,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          line2: Text(
            artistName,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
          line3: Text(
            albumName,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontStyle: FontStyle.italic,
            ),
          ),
          duration: duration,
          isExplicit: isExplicit,
          onPlayPress: onPlayPress,
        );

  static const separator = ThreeLineListTile.separator;
}
