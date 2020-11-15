import 'package:epimetheus/core/ui/widgets/playable.dart';
import 'package:epimetheus/features/collection/ui/widgets/list_tiles/three_line_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:iapetus/iapetus.dart';

class AlbumListTile extends Playable<Album> {
  final AlbumAnnotation annotation;

  const AlbumListTile(Album item, this.annotation) : super(item);

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
        'Collected ${item.collectedSongCount ?? annotation.songCount}/${annotation.songCount} tracks',
        softWrap: false,
        overflow: TextOverflow.ellipsis,
      ),
      duration: annotation.duration,
      isExplicit: annotation.isExplicit,
    );
  }

  static const separator = ThreeLineListTile.separator;
}
