import 'package:epimetheus/features/playback/entities/queue_display_item.dart';
import 'package:epimetheus/features/playback/ui/widgets/lyric_card.dart';
import 'package:flutter/material.dart';

class QueueDisplaySongInfo extends StatelessWidget {
  final QueueDisplayItem queueItem;
  final bool isDominantColorDark;

  const QueueDisplaySongInfo({
    Key? key,
    required this.queueItem,
    required this.isDominantColorDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final foregroundColor = isDominantColorDark ? Colors.white : Colors.black;
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          // mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              queueItem.mediaItem.title,
              textScaleFactor: 1.3,
              style: TextStyle(
                color: foregroundColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              queueItem.mediaItem.artist,
              textScaleFactor: 1.2,
              style: TextStyle(
                color: foregroundColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              queueItem.mediaItem.album,
              textScaleFactor: 1.2,
              style: TextStyle(
                color: foregroundColor,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            if (queueItem.lyricSnippet != null)
              SizedBox(
                width: MediaQuery.of(context).size.width - 72,
                child: LyricCard(
                  lyricSnippet: queueItem.lyricSnippet!,
                  isDominantColorDark: isDominantColorDark,
                  foregroundColor: foregroundColor,
                ),
              )
          ],
        ),
      ),
    );
  }
}
