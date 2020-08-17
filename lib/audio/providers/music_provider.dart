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
  /// Called when the MusicProvider is received in the isolate.
  void init();

  /// A unique id for the MusicProvider.
  String get id;

  /// A human-readable title for the music collection.
  String get title;

  /// The number of media items in the playlist.
  int get count;

  /// The currently playing audio URL
  String get audioUrl;

  /// The media queue.
  List<MediaItem> get queue;

  /// The currently playing [MediaItem] data.
  MediaItem get currentMediaItem;

  /// Skip to a media item.
  void skipTo(int index);

  /// Skip to the next media item.
  void skip() => skipTo(1);

  /// Removes the media item at the given index.
  void remove(int index);

  /// Rates the media item at the given index.
  Future<void> rate(User user, int index, Rating rating, bool update);

  /// Shelves the media item for a month.
  void tired(int index);

  /// Loads more media items.
  /// Returns a list of the new URLs.
  Future<List<String>> load(User user);

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
