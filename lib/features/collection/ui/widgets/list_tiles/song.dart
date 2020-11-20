import 'package:epimetheus/core/ui/widgets/track_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:iapetus/iapetus.dart';

class SongListTile extends StatelessWidget {
  final Song item;
  final SongAnnotation annotation;
  final VoidCallback? onPlayPress;

  SongListTile(
    this.item,
    this.annotation, {
    this.onPlayPress,
  });

  @override
  Widget build(BuildContext context) {
    return TrackListTile<Song>(
      item,
      name: annotation.name,
      artistName: annotation.artistName,
      albumName: annotation.albumName,
      duration: annotation.duration,
      isExplicit: annotation.isExplicit,
      artUrl: annotation.art.recommendedUri?.toString(),
      onPlayPress: onPlayPress,
    );
  }

  static const separator = TrackListTile.separator;
}
