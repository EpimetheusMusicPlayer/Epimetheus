import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/art_constants.dart';
import 'package:epimetheus/audio/providers/music_provider.dart';
import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:epimetheus/libepimetheus/songs.dart';
import 'package:epimetheus/libepimetheus/stations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class StationMusicProvider extends MusicProvider {
  final List<Station> _stations;
  final int _stationIndex;

  final List<Song> _songs = List<Song>();
  BaseCacheManager _cacheManager;

  StationMusicProvider(this._stations, this._stationIndex);

  @override
  void init() {
    _cacheManager = DefaultCacheManager();
  }

  @override
  BaseCacheManager get cacheManager => _cacheManager;

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
    final List<MediaItem> queue = [];
    for (int i = 0; i < _songs.length; i++) {
      final artUrl = _songs[i].getArtUrl(serviceArtSize);

      queue.add(
        MediaItem(
          id: _songs[i].pandoraId,
          title: _songs[i].title,
          artist: _songs[i].artistTitle,
          album: _songs[i].albumTitle,
          artUri: artUrl,
          displayTitle: _songs[i].title,
          displaySubtitle: '${_songs[i].artistTitle} - ${_songs[i].albumTitle}',
          displayDescription: title,
          playable: true,
          rating: _songs[i].rating,
          genre: artUrl + '|' + (_songs[i].pendingRating.isRated() ? _songs[i].pendingRating.isThumbUp().toString() : 'null'),
        ),
      );
    }

    return queue;
  }

  @override
  MediaItem get currentMediaItem {
    final artUrl = _songs[0].getArtUrl(serviceArtSize);

    return MediaItem(
      id: _songs[0].pandoraId,
      title: _songs[0].title,
      artist: _songs[0].artistTitle,
      album: _songs[0].albumTitle,
      artUri: artUrl,
      displayTitle: _songs[0].title,
      displaySubtitle: '${_songs[0].artistTitle} - ${_songs[0].albumTitle}',
      displayDescription: '$title',
      playable: true,
      rating: _songs[0].rating,
      genre: artUrl + '|' + (_songs[0].pendingRating.isRated() ? _songs[0].pendingRating.isThumbUp().toString() : 'null'),
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
      List<Song> newSongs = await _stations[_stationIndex].getPlaylistFragment(user);
      _songs.addAll(newSongs);

      // Cache the album art
      for (Song song in newSongs) {
        _cacheManager.downloadFile(song.getArtUrl(serviceArtSize)).catchError(
              (error) {},
              test: (error) => error is HttpException || error is SocketException,
            );
      }

      return newSongs.map<String>((Song song) => song.audioUrl).toList(growable: false);
    } catch (error) {
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
