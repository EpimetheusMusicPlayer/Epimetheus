import 'package:epimetheus/features/playback/entities/queue_display_item.dart';
import 'package:epimetheus/features/playback/ui/widgets/queue_display_song_info.dart';
import 'package:epimetheus/features/playback/ui/widgets/seekbar.dart';
import 'package:flutter/material.dart';

class QueueDisplaySongControls extends StatelessWidget {
  final QueueDisplayItem queueItem;
  final bool isDominantColorDark;

  const QueueDisplaySongControls({
    Key? key,
    required this.queueItem,
    required this.isDominantColorDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        QueueDisplaySongInfo(
          queueItem: queueItem,
          isDominantColorDark: isDominantColorDark,
        ),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 32,
              child: Seekbar(
                mediaItem: queueItem.mediaItem,
                isDominantColorDark: isDominantColorDark,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
