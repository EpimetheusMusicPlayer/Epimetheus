/// This class defines keys to [MediaItem] extras provided by the audio task.
class AudioTaskKeys {
  /// The [AudioService.currentMediaItem]'s extras will always contain the
  /// item's index in the queue, assigned to this key.
  static const mediaItemIndex = 'index';

  /// All [MediaItem]s will provide a serialized [AudioTaskLyricSnippet] at this
  /// key (when possible).
  static const lyricSnippet = 'lyricSnippet';
}
