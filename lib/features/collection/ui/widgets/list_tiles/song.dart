import 'package:epimetheus/core/ui/widgets/track_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:iapetus/iapetus.dart';

class SongListTile extends TrackListTile {
  SongListTile({
    bool playing = false,
    required SongAnnotation annotation,
    VoidCallback? onPlayPress,
  }) : super(
          playing: playing,
          name: annotation.name,
          artistName: annotation.artistName,
          albumName: annotation.albumName,
          duration: annotation.duration,
          isExplicit: annotation.isExplicit,
          artUrl: annotation.art.recommendedUri?.toString(),
          onPlayPress: onPlayPress,
        );

  static const separator = TrackListTile.separator;
}
