import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/features/playback/entities/audio_task_keys.dart';
import 'package:epimetheus/features/playback/entities/audio_task_lyric_snippet.dart';
import 'package:epimetheus/features/playback/services/audio_task/media_sources/media_source.dart';
import 'package:iapetus/iapetus.dart';

class StationMediaSource implements MediaSource {
  /// The station being used to provide audio.
  final Station _station;

  StationMediaSource(this._station);

  final List<StationSong> _songs = [];

  @override
  Future<bool> init(Iapetus iapetus) async => true;

  @override
  void dispose() {}

  /// Uses the [Station.stationId] as the identifier.
  @override
  String get id => _station.stationId;

  /// Uses the [Station.name] as the human-readable title.
  @override
  String get title => _station.name;

  /// Stations always play from the song first provided by Pandora's API.
  @override
  int currentQueueIndex = 0;

  @override
  void notifySkipTo(int index) => currentQueueIndex = index;

  @override
  bool get mediaCanBeRated => true;

  @override
  Future<void> rate(Iapetus iapetus, int index, Rating rating) {
    // TODO implement station media rating
    throw UnimplementedError();
  }

  @override
  void tired(int index) {
    // TODO implement station media tired setting
    throw UnimplementedError();
  }

  @override
  bool get shouldLoad => _songs.length - currentQueueIndex <= 2;

  @override
  Future<List<MediaItem>> load(
    Iapetus iapetus, [
    bool initialLoad = false,
  ]) async {
    try {
      // Load the new songs, ignoring anything other than real tracks (things like
      // artist messages have slightly different properties and need special
      // treatment, and they're basically ads anyway).
      final newSongs = (await _station.getFragment(
        iapetus: iapetus,
        isStationStart: initialLoad,
        audioQuality: AudioQuality.high,
      ))
          .where((song) => song.trackType == TrackType.track);

      _songs.addAll(newSongs);

      return [for (final song in newSongs) song.asMediaItem];
    } on IapetusNetworkException catch (e) {
      throw MediaSourceLoadException(e);
    } on InvalidatedSessionException {
      throw const InvalidatedMediaSourceSessionException();
    }
  }

  @override
  Uri getAudioUri(int index) => Uri.parse(_songs[index].audioUrl);

  @override
  double getVolumeFor(int index) => _songs[index].volumeFraction;

  @override
  List<MediaItem> getChildren(String parentId) {
    // TODO: implement getChildren
    return const [];
  }
}

extension _StationSongConvertions on StationSong {
  MediaItem get asMediaItem => MediaItem(
        id: pandoraId,
        album: albumTitle,
        title: songTitle,
        artist: artistName,
        genre: genre.isEmpty ? null : genre.first,
        duration: trackLength,
        artUri: art.recommendedUri?.toString(),
        playable: true,
        displayDescription: '$artistName - $albumTitle',
        // TODO rating
        extras: {
          AudioTaskKeys.lyricSnippet: lyricSnippet?.toMap(),
        },
      );
}
