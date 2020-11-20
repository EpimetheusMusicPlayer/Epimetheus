import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/features/playback/ui/widgets/queue_display_song_info.dart';
import 'package:epimetheus/features/playback/ui/widgets/seekbar.dart';
import 'package:flutter/material.dart';

class QueueDisplaySongControls extends StatelessWidget {
  final MediaItem mediaItem;
  final bool isDominantColorDark;

  const QueueDisplaySongControls({
    Key? key,
    required this.mediaItem,
    required this.isDominantColorDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        QueueDisplaySongInfo(
          mediaItem: mediaItem,
          isDominantColorDark: isDominantColorDark,
        ),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 32,
              child: Seekbar(
                mediaItem: mediaItem,
                isDominantColorDark: isDominantColorDark,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
