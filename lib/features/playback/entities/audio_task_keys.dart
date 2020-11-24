/// This class defines keys to global audio task metadata, found in the
/// [MediaItem] provided by [AudioService.currentMediaItem].
class AudioTaskMetadataKeys {
  /// A unique identifier that can be used to identify the audio source in use.
  /// Usually a Pandora ID.
  static const mediaSourceId = 'id';

  /// The index of the currently playing media item in the queue.
  static const currentlyPlayingQueueIndex = 'index';
}

/// This class defines keys to [MediaItem] extras in the audio task's queue.
class QueueItemMetadataKeys {
  /// All [MediaItem]s will provide a serialized [AudioTaskLyricSnippet] at this
  /// key (when possible).
  static const lyricSnippet = 'lyricSnippet';
}
