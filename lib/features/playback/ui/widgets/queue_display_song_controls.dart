import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:epimetheus/features/playback/entities/queue_display_item.dart';
import 'package:epimetheus/features/playback/ui/widgets/queue_display_song_info.dart';
import 'package:epimetheus/features/playback/ui/widgets/seekbar.dart';
import 'package:flutter/material.dart';

class QueueDisplaySongControls extends StatelessWidget {
  final bool selected;
  final bool isSelectedChanging;
  final double transitionOpacity;
  final MediaItem playingMediaItem;
  final QueueDisplayItem selectedQueueItem;
  final Color dominantColor;
  final bool isDominantColorDark;
  final VoidCallback selectPlaying;

  const QueueDisplaySongControls({
    Key? key,
    required this.selected,
    required this.isSelectedChanging,
    required this.transitionOpacity,
    required this.playingMediaItem,
    required this.selectedQueueItem,
    required this.dominantColor,
    required this.isDominantColorDark,
    required this.selectPlaying,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget _buildSelectChip() {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Opacity(
          // The chip seems to change slightly when opacity is applied to
          // it. As a workaround, opacity is always applied to maintain
          // visual consistency.
          opacity: (selected ? 0 : 0.99),
          child: ActionChip(
            avatar: playingMediaItem.artUri == null
                ? null
                : CircleAvatar(
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
            elevation: 1,
            pressElevation: 0.5,
            onPressed: selectPlaying,
          ),
        ),
      );
    }

    Widget _buildControls() {
      return SizedBox(
        width: MediaQuery.of(context).size.width - 32,
        child: Seekbar(
          mediaItem: selectedQueueItem.mediaItem,
          isDominantColorDark: isDominantColorDark,
        ),
      );
    }

    return Column(
      children: [
        Opacity(
          opacity: transitionOpacity,
          child: QueueDisplaySongInfo(
            queueItem: selectedQueueItem,
            isDominantColorDark: isDominantColorDark,
          ),
        ),
        Expanded(
          child: Opacity(
            opacity: isSelectedChanging ? transitionOpacity : 1,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: selected ? _buildControls() : _buildSelectChip(),
            ),
          ),
        ),
      ],
    );
  }
}
