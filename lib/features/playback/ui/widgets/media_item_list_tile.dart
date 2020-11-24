import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/core/ui/widgets/track_list_tile.dart';

class MediaItemListTile extends TrackListTile {
  MediaItemListTile({
    bool playing = false,
    required MediaItem mediaItem,
    required bool isExplicit,
  }) : super(
          playing: playing,
          name: mediaItem.title,
          artistName: mediaItem.artist,
          albumName: mediaItem.album,
          duration: mediaItem.duration,
          isExplicit: isExplicit,
          artUrl: mediaItem.artUri,
        );

  static const separator = TrackListTile.separator;
}
