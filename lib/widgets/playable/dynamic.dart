import 'package:epimetheus/libepimetheus/structures/pandora_entity.dart';
import 'package:epimetheus/widgets/playable/album.dart';
import 'package:epimetheus/widgets/playable/artist.dart';
import 'package:epimetheus/widgets/playable/playable.dart';
import 'package:epimetheus/widgets/playable/playlist.dart';
import 'package:epimetheus/widgets/playable/track.dart';
import 'package:flutter/material.dart';

/// This widget will chose an appropriate child based on the [PandoraEntity] that it's given.
class DynamicPlayableListTile extends PlayableWidget<PandoraEntity> {
  const DynamicPlayableListTile(
    PandoraEntity item, {
    VoidCallback onPlayPress,
  }) : super(item, onPlayPress: onPlayPress);

  @override
  Widget build(BuildContext context) {
    switch (item.type) {
      case PandoraEntityType.track:
        return TrackListTile(item, onPlayPress: onPlayPress);
      case PandoraEntityType.playlist:
        return PlaylistListTile(item, onPlayPress: onPlayPress);
      case PandoraEntityType.artist:
        return ArtistListTile(item);
      case PandoraEntityType.album:
        return AlbumListTile(item);
      default:
        return null;
    }
  }
}
