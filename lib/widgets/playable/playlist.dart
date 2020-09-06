import 'package:epimetheus/libepimetheus/playlists.dart';
import 'package:epimetheus/widgets/playable/playable.dart';
import 'package:epimetheus/widgets/playable/three_line_list_tile.dart';
import 'package:fast_marquee/fast_marquee.dart';
import 'package:flutter/material.dart';

class PlaylistListTile extends PlayableWidget<Playlist> {
  PlaylistListTile(
    Playlist item, {
    VoidCallback onPlayPress,
  }) : super(item, onPlayPress: onPlayPress);

  @override
  Widget build(BuildContext context) {
    return ThreeLineMediaListTile(
      artUrl: item.getArtUrl(500),
      line1: Text(
        item.name,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      line2: Marquee(
        text: item.description.isNotEmpty ? item.description : 'No description.',
        style: const TextStyle(
          inherit: true,
          color: const Color(0xdd000000),
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
      duration: item.duration,
      isExplicit: false, // Playlists don't get flagged as explicit, no matter their contents.
      onPlayPress: onPlayPress,
    );
  }
}
