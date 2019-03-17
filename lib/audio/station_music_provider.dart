import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/art_constants.dart';
import 'package:epimetheus/audio/music_provider.dart';
import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:epimetheus/libepimetheus/songs.dart';
import 'package:epimetheus/libepimetheus/stations.dart';

class StationMusicProvider extends MusicProvider {
  final List<Station> _stations;
  final int _stationIndex;

  final List<Song> _songs = List<Song>();

  StationMusicProvider(this._stations, this._stationIndex);

  @override
  String get title => _stations[_stationIndex].title;

  @override
  int get count => _songs.length;

  @override
  String get audioUrl => _songs[0].audioUrl;

  @override
  List<MediaItem> get queue {
    return _songs.map<MediaItem>((Song song) {
      return MediaItem(
        id: song.pandoraId,
        title: song.title,
        artist: song.artistTitle,
        album: song.albumTitle,
        artUri: song.getArtUrl(serviceArtSize),
        displayTitle: song.title,
        displaySubtitle: '${song.artistTitle} - ${song.albumTitle}',
        displayDescription: title,
        playable: true,
        rating: song.rating,
      );
    }).toList(growable: false);
  }

  @override
  MediaItem get currentMediaItem {
    return MediaItem(
      id: _songs[0].pandoraId,
      title: _songs[0].title,
      artist: _songs[0].artistTitle,
      album: _songs[0].albumTitle,
      artUri: _songs[0].getArtUrl(serviceArtSize),
      displayTitle: _songs[0].title,
      displaySubtitle: '${_songs[0].artistTitle} - ${_songs[0].albumTitle}',
      displayDescription: '$title',
      playable: true,
      rating: _songs[0].rating,
    );
  }

  @override
  void skipTo(int index) {
    _songs.removeRange(0, index);
  }

  @override
  void skip() {
    _songs.removeAt(0);
  }

  @override
  void remove(int index) {
    _songs.removeAt(index);
  }

  @override
  void rate(int index, Rating rating) {}

  @override
  void tired(int index) {}

  @override
  Future<List<String>> load(User user) async {
    try {
      List<Song> newSongs = await _stations[_stationIndex].getPlaylistFragment(user);
      _songs.addAll(newSongs);
      return newSongs.map<String>((Song song) => song.audioUrl).toList(growable: false);
    } catch (error) {
      return null;
    }
  }

  List<MediaItem> getChildren(String parentId) {
    // TODO implement getChildren()
  }

  @override
  bool operator ==(dynamic other) {
    if (other is StationMusicProvider) {
      return _stations[_stationIndex].pandoraId == other._stations[other._stationIndex].pandoraId;
    } else {
      return true;
    }
  }
}
