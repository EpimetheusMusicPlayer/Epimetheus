import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/art_constants.dart';
import 'package:epimetheus/audio/providers/music_provider.dart';
import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:epimetheus/libepimetheus/songs.dart';
import 'package:epimetheus/libepimetheus/stations.dart';
import 'package:flutter/material.dart';

class StationMusicProvider extends MusicProvider {
  final List<Station> _stations;
  final int _stationIndex;

  final List<Song> _songs = List<Song>();

  StationMusicProvider(this._stations, this._stationIndex);

  @override
  void init() {}

  @override
  String get id => _stations[_stationIndex].stationId;

  @override
  String get title => _stations[_stationIndex].title;

  @override
  int get count => _songs.length;

  @override
  String get audioUrl => _songs[0].audioUrl;

  @override
  List<MediaItem> get queue {
    return [
      for (Song song in _songs)
        MediaItem(
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
          genre: song.pendingRating.isRated() ? song.pendingRating.isThumbUp().toString() : 'null',
        ),
    ];
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
      genre: _songs[0].pendingRating.isRated() ? _songs[0].pendingRating.isThumbUp().toString() : 'null',
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
  Future<void> rate(User user, int index, Rating rating, bool update) {
    if (update) {
      _songs[index].updateFeedbackLocally(rating);
      return Future.value();
    } else {
      if (rating.isRated()) {
        return _songs[index].addFeedback(user, rating.isThumbUp());
      } else {
        return _songs[index].deleteFeedback(user);
      }
    }
  }

  @override
  void tired(int index) {}

  @override
  Future<List<String>> load(User user) async {
    try {
      // Download the next few song entries
      List<Song> newSongs = await _stations[_stationIndex].getPlaylistFragment(user);

      // Add the new entries to the internally managed queue
      _songs.addAll(newSongs);

      // Return the new songs to be added into the audio service's queue
      return newSongs.map<String>((Song song) => song.audioUrl).toList(growable: false);
    } catch (error) {
      throw error;
      return null; // TODO handle errors
    }
  }

  @override
  List<MediaItem> getChildren(String parentId) {
    // TODO implement getChildren()
  }

  @override
  List<MusicProviderAction> getActions(State state) => [
        if (!_stations[_stationIndex].isShuffle)
          MusicProviderAction(
            iconData: Icons.thumbs_up_down,
            label: 'Station feedback',
            onTap: () {
//              openFeedbackPage(state.context, _stations[_stationIndex]);
            },
          )
      ];
}
