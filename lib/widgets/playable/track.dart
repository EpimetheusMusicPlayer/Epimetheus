import 'package:epimetheus/libepimetheus/songs.dart';
import 'package:epimetheus/libepimetheus/structures/pandora_entity.dart';
import 'package:epimetheus/widgets/playable/playable.dart';
import 'package:epimetheus/widgets/playable/three_line_list_tile.dart';
import 'package:flutter/material.dart';

class TrackListTile extends PlayableWidget<Track> {
  TrackListTile(
    Track item, {
    VoidCallback onPlayPress,
  }) : super(item, onPlayPress: onPlayPress);

  @override
  Widget build(BuildContext context) {
    return ThreeLineMediaListTile(
      artUrl: item.getArtUrl(500),
      line1: Text(
        item.title,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      line2: Text(
        item.artistTitle,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
      ),
      line3: Text(
        item.albumTitle,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontStyle: FontStyle.italic,
        ),
      ),
      duration: item.duration,
      isExplicit: item.explicitness == PandoraEntityExplicitness.explicit,
      onPlayPress: onPlayPress,
    );
  }
}
