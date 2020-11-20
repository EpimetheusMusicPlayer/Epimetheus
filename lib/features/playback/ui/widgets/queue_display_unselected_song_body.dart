import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:epimetheus/features/playback/entities/queue_display_item.dart';
import 'package:epimetheus/features/playback/ui/widgets/queue_display_song_info.dart';
import 'package:flutter/material.dart';

class QueueDisplayUnselectedSongBody extends StatelessWidget {
  final MediaItem playingMediaItem;
  final QueueDisplayItem selectedQueueItem;
  final Color dominantColor;
  final bool isDominantColorDark;
  final VoidCallback selectPlaying;

  const QueueDisplayUnselectedSongBody({
    Key? key,
    required this.playingMediaItem,
    required this.selectedQueueItem,
    required this.dominantColor,
    required this.isDominantColorDark,
    required this.selectPlaying,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        QueueDisplaySongInfo(
          queueItem: selectedQueueItem,
          isDominantColorDark: isDominantColorDark,
        ),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ActionChip(
                avatar: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                    playingMediaItem.artUri,
                  ),
                ),
                label: Text(
                  'Now playing: ${playingMediaItem.title} by ${playingMediaItem.artist}',
                ),
                backgroundColor: dominantColor.withAlpha(200),
                labelStyle: TextStyle(
                  color: isDominantColorDark ? Colors.white : Colors.black,
                ),
                elevation: 2,
                pressElevation: 1,
                onPressed: selectPlaying,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
