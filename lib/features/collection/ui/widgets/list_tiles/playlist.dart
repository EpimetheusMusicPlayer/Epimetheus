import 'package:epimetheus/core/ui/widgets/playable.dart';
import 'package:epimetheus/features/collection/ui/widgets/list_tiles/three_line_list_tile.dart';
import 'package:fast_marquee/fast_marquee.dart';
import 'package:flutter/material.dart';
import 'package:iapetus/iapetus.dart';

class PlaylistListTile extends Playable<Playlist> {
  final PlaylistAnnotation annotation;

  PlaylistListTile(
    Playlist item,
    this.annotation, {
    VoidCallback? onPlayPress,
  }) : super(item, onPlayPress: onPlayPress);

  @override
  Widget build(BuildContext context) {
    return ThreeLineMediaListTile(
      artUrl: annotation.art.recommendedUri?.toString(),
      line1: Text(
        item.name,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      line2: Marquee(
        text: annotation.description.isNotEmpty
            ? annotation.description
            : 'No description.',
        style: const TextStyle(
          inherit: true,
          color: Color(0xdd000000),
          fontStyle: FontStyle.italic,
        ),
        blankSpace: 50,
        startAfter: const Duration(seconds: 2),
        pauseAfterRound: const Duration(seconds: 2),
        fadingEdgeStartFraction: 0.05,
        fadingEdgeEndFraction: 0.05,
      ),
      line3: Text(
        'Updated ${item.updatedTime}',
        softWrap: false,
        overflow: TextOverflow.ellipsis,
      ),
      duration: annotation.duration,
      isExplicit: false,
      // Playlists don't get flagged as explicit, no matter their contents.
      onPlayPress: onPlayPress,
    );
  }

  static const separator = ThreeLineListTile.separator;
}
