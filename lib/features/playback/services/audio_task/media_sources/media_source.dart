import 'package:audio_service/audio_service.dart';
import 'package:iapetus/iapetus.dart';

/// An [MediaSource] provides audio.
///
/// It's an abstraction that the background audio task uses to be able to play
/// different types of media, like stations and playlists, without any changes
/// to its code.
abstract class MediaSource {
  const MediaSource();

  /// Called when the source is received in the isolate.
  /// Returns true if initialisation is successful.
  Future<bool> init(Iapetus iapetus);

  /// Called when the source is no longer needed, and
  /// about to be destroyed.
  void dispose();

  /// A unique identifier for the source.
  ///
  /// No two sources should have the same identifier, unless they represent
  /// identical media.
  String get id;

  /// A human-readable title representing the source.
  ///
  /// May be used in the UI.
  String get title;

  /// The index of the currently playing item in the audio service queue.
  int get currentQueueIndex;

  /// Notifies the source that the player has skipped to the given index.
  void notifySkipTo(int index);

  /// True if the media can be rated.
  bool get mediaCanBeRated;

  /// Sets the media item rating at the given index.
  Future<void> rate(Iapetus iapetus, int index, Rating rating);

  /// Shelves the media item for a month, in applicable source types.
  void tired(int index);

  /// Returns true if the service should load a new page of media
  /// (if the page count is getting low).
  bool get shouldLoad;

  // TODO error handling in load
  /// Loads more media items.
  /// Returns a list of the new [MediaItem]s.
  Future<List<MediaItem>> load(Iapetus iapetus, [bool initialLoad = false]);

  /// Returns an audio URL for the given index. May be null if none is
  /// available.
  Uri getAudioUri(int index);

  /// Gets the relative volume for the media item at the given index, in the
  /// form of a decimal where 1.0 is the standard volume.
  double getVolumeFor(int index);

  /// Get a list of media groups to play (e.g. stations).
  List<MediaItem> getChildren(String parentId);

  // /// A list of actions related to the source to be shown in the UI.
  // List<MusicProviderAction> getActions(State state) => const [];

  @override
  bool operator ==(other) {
    if (other is MediaSource) {
      return id == other.id;
    } else {
      return false;
    }
  }
}

abstract class MediaSourceException implements Exception {
  const MediaSourceException();
}

class InvalidatedMediaSourceSessionException extends MediaSourceException {
  const InvalidatedMediaSourceSessionException();
}

class MediaSourceLoadException extends MediaSourceException {
  /// The implementation-specific caught object.
  final dynamic inner;

  const MediaSourceLoadException(this.inner);
}
