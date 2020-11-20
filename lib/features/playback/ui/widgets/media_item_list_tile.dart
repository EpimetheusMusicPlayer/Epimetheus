import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/core/ui/widgets/track_list_tile.dart';
import 'package:flutter/material.dart';

class MediaItemListTile extends StatelessWidget {
  final MediaItem mediaItem;
  final bool isExplicit;
  final VoidCallback? onPlayPress;

  const MediaItemListTile({
    Key? key,
    required this.mediaItem,
    required this.isExplicit,
    this.onPlayPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TrackListTile<MediaItem>(
      mediaItem,
      name: mediaItem.title,
      artistName: mediaItem.artist,
      albumName: mediaItem.album,
      duration: mediaItem.duration,
      isExplicit: isExplicit,
      artUrl: mediaItem.artUri,
    );
  }

  static const separator = TrackListTile.separator;
}
