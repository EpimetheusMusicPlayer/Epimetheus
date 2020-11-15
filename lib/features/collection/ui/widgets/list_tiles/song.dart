import 'package:epimetheus/core/ui/widgets/playable.dart';
import 'package:epimetheus/features/collection/ui/widgets/list_tiles/three_line_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:iapetus/iapetus.dart';

class SongListTile extends Playable<Song> {
  final SongAnnotation annotation;

  SongListTile(
    Song item,
    this.annotation, {
    VoidCallback? onPlayPress,
  }) : super(
          item,
          onPlayPress: onPlayPress,
        );

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
      line2: Text(
        annotation.artistName,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
      ),
      line3: Text(
        annotation.albumName,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontStyle: FontStyle.italic,
        ),
      ),
      duration: annotation.duration,
      isExplicit: annotation.isExplicit,
      onPlayPress: onPlayPress,
    );
  }

  static const separator = ThreeLineListTile.separator;
}
