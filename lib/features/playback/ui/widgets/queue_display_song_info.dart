import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

class QueueDisplaySongInfo extends StatelessWidget {
  final MediaItem mediaItem;
  final bool isDominantColorDark;

  const QueueDisplaySongInfo({
    Key? key,
    required this.mediaItem,
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
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              mediaItem.title,
              textScaleFactor: 1.3,
              style: TextStyle(
                color: foregroundColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              mediaItem.artist,
              textScaleFactor: 1.2,
              style: TextStyle(
                color: foregroundColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              mediaItem.album,
              textScaleFactor: 1.2,
              style: TextStyle(
                color: foregroundColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
