import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/features/playback/entities/audio_task_keys.dart';
import 'package:epimetheus/features/playback/entities/audio_task_lyric_snippet.dart';
import 'package:iapetus/iapetus.dart';

/// This class holds data that is unserialised from a MediaItem provided by the
/// audio task.
///
/// [mapMediaItem] and [mapQueue] can be directly plugged in to [Stream.map].
class QueueDisplayItem {
  final MediaItem mediaItem;
  final LyricSnippet? lyricSnippet;

  QueueDisplayItem({
    required this.mediaItem,
    required this.lyricSnippet,
  });

  static QueueDisplayItem? mapMediaItem(MediaItem? mediaItem) {
    if (mediaItem == null) return null;
    return mediaItem.unpack();
  }

  static List<QueueDisplayItem>? mapQueue(List<MediaItem>? queue) {
    if (queue == null) return null;
    return [for (final mediaItem in queue) mediaItem.unpack()];
  }
}

extension on MediaItem {
  QueueDisplayItem unpack() {
    final lyricSnippetMap = extras[AudioTaskKeys.lyricSnippet];
    return QueueDisplayItem(
      mediaItem: this,
      lyricSnippet: lyricSnippetMap == null
          ? null
          : AudioTaskLyricSnippet.fromMap(lyricSnippetMap),
    );
  }
}
