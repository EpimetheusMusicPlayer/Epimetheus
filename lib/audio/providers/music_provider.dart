import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:flutter/widgets.dart';

class MusicProviderAction {
  final IconData iconData;
  final String label;
  final VoidCallback onTap;

  const MusicProviderAction({
    @required this.iconData,
    @required this.label,
    @required this.onTap,
  });
}

abstract class MusicProvider {
  /// True if the media items can be rated
  final bool canRateItems;

  MusicProvider({
    this.canRateItems = false,
  });

  /// Called when the MusicProvider is received in the isolate.
  /// Returns true if initialisation is successful.
  Future<bool> init(User user);

  /// Called when the MusicProvider is no longer needed, and
  /// about to be destroyed.
  void dispose();

  /// A unique id for the MusicProvider.
  String get id;

  /// A human-readable title for the music collection.
  String get title;

  /// The index of the currently playing item in the audio service queue.
  int get currentQueueIndex;
  set currentQueueIndex(int value);

  /// Called before skipping so the provider prepares.
  /// Returns a list of audio URIs that may need to be added to the player.
  ///
  /// Note: if the whole queue is not known for the type of media this a provider
  /// provides, this should not be overridden. Instead, [load] and [shouldLoad]
  /// should be implemented properly to provide pages. When the service receives
  /// a new page, it will then ask for new URIs through [getAudioUri]. As this
  /// will not happen when no new pages are added, this method exists to let
  /// providers that give the entire queue at once (without all the audio URIs)
  /// to add URIs when necessary.
  Future<List<Uri>> prepareSkipTo(User user, String id) async => const [];

  /// Notifies the provider after a player skips to a media item.
  void notifySkipTo(int index) {}

  /// Called before skipping so the provider prepares.
  /// Returns a list of audio URIs that may need to be added to the player.
  ///
  /// Note: if the whole queue is not known for the type of media this a provider
  /// provides, this should not be overridden. Instead, [load] and [shouldLoad]
  /// should be implemented properly to provide pages. When the service receives
  /// a new page, it will then ask for new URIs through [getAudioUri]. As this
  /// will not happen when no new pages are added, this method exists to let
  /// providers that give the entire queue at once (without all the audio URIs)
  /// to add URIs when necessary.
  Future<List<Uri>> prepareSkip(User user, int oldIndex) async => const [];

  /// Notifies the provider after a player skips to the next media item.
  void notifySkip(int newIndex) {}

  /// Rates the media item at the given index.
  Future<void> rate(User user, int index, Rating rating, bool update);

  /// Shelves the media item for a month.
  void tired(int index);

  /// Loads more media items.
  /// Returns a list of the new [MediaItem]s.
  Future<List<MediaItem>> load(User user);

  /// Returns true if the service should load a new page
  /// (if the page count is getting low).
  ///
  /// Note: if all pages (that is, the whole queue) are available with the
  /// first load, this should always return false. If not all audio URIs
  /// are known, they can be provided when needed by overriding [prepareSkip]
  /// and [prepareSkipTo].
  bool shouldLoad();

  /// Returns an audio URL for the given index. May be null if none is available.
  Uri getAudioUri(int index);

  /// Get a list of media groups to play (e.g. stations).
  List<MediaItem> getChildren(String parentId);

  /// A list of actions related to the MusicProvider to be shown in the UI.
  List<MusicProviderAction> getActions(State state) => const [];

  @override
  bool operator ==(other) {
    if (other is MusicProvider)
      return id == other.id;
    else
      return false;
  }
}
