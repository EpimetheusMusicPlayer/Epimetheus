import 'package:epimetheus/libepimetheus/albums.dart';
import 'package:epimetheus/libepimetheus/structures/pandora_entity.dart';
import 'package:epimetheus/widgets/playable/playable.dart';
import 'package:epimetheus/widgets/playable/three_line_list_tile.dart';
import 'package:flutter/material.dart';

class AlbumListTile extends PlayableWidget<Album> {
  const AlbumListTile(Album item) : super(item);

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
      line2: Text(
        item.artistName,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
      ),
      line3: Text(
        'Collected ${item.collectedTrackCount}/${item.trackCount} tracks',
        softWrap: false,
        overflow: TextOverflow.ellipsis,
      ),
      duration: item.duration,
      isExplicit: item.explicitness == PandoraEntityExplicitness.explicit,
    );
  }
}
