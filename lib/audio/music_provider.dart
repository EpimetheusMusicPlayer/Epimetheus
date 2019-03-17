import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/libepimetheus/authentication.dart';

abstract class MusicProvider {
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
  void rate(int index, Rating rating);

  /// Shelves the media item for a month.
  void tired(int index);

  /// Loads more media items.
  /// Returns a list of the new URLs.
  Future<List<String>> load(User user);

  /// Get a list of media groups to play (e.g. stations).
  List<MediaItem> getChildren(String parentId);

  /// Returns true if the given provider is different to the current one.
//  bool shouldReplace(MusicProvider other);
}
