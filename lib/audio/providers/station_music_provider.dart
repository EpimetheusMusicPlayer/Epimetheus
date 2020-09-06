import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/art_constants.dart';
import 'package:epimetheus/audio/providers/music_provider.dart';
import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:epimetheus/libepimetheus/stations.dart';
import 'package:epimetheus/libepimetheus/tracks.dart';
import 'package:flutter/material.dart';

class StationMusicProvider extends MusicProvider {
  final Station _station;
  final List<Station> _catalogue;

  final List<StationTrack> _tracks = <StationTrack>[];

  StationMusicProvider(this._station, this._catalogue) : super(canRateItems: true);

  @override
  Future<bool> init(User user) async => true;

  @override
  void dispose() {}

  @override
  String get id => _station.stationId;

  @override
  String get title => _station.title;

  @override
  int currentQueueIndex = 0;

  @override
  void notifySkipTo(int index) => currentQueueIndex = index;

  @override
  void notifySkip(int newIndex) => ++currentQueueIndex;

  @override
  Future<void> rate(User user, int index, Rating rating, bool update) {
    if (update) {
      _tracks[index].updateFeedbackLocally(rating);
      return Future.value();
    } else {
      if (rating.isRated()) {
        return _tracks[index].addFeedback(user, rating.isThumbUp());
      } else {
        return _tracks[index].deleteFeedback(user);
      }
    }
  }

  @override
  void tired(int index) {}

  @override
  Future<List<MediaItem>> load(User user) async {
    try {
      // Download the next few song entries
      List<StationTrack> newTracks = await _station.getPlaylistFragment(user);

      // Add the new entries to the internally managed queue
      _tracks.addAll(newTracks);

      // Return the new songs to be added into the audio service's queue
      return _tracksToMediaItems(newTracks);
    } catch (error) {
      throw error;
      return null; // TODO handle errors
    }
  }

  @override
  bool shouldLoad() {
    return _tracks.length - currentQueueIndex <= 2;
  }

  @override
  Uri getAudioUri(int index) => Uri.parse(_tracks[index].audioUrl);

  @override
  List<MediaItem> getChildren(String parentId) {
    // TODO implement getChildren()
  }

  @override
  List<MusicProviderAction> getActions(State state) => [
        if (!_station.isShuffle)
          MusicProviderAction(
            iconData: Icons.thumbs_up_down,
            label: 'Station feedback',
            onTap: () {
//              openFeedbackPage(state.context, _stations[_stationIndex]);
            },
          )
      ];

  List<MediaItem> _tracksToMediaItems(List<StationTrack> tracks) {
    return [
      for (final track in tracks)
        MediaItem(
          id: track.pandoraId,
          title: track.title,
          artist: track.artistTitle,
          album: track.albumTitle,
          artUri: track.getArtUrl(serviceArtSize),
          displayTitle: track.title,
          displaySubtitle: '${track.artistTitle} - ${track.albumTitle}',
          displayDescription: title,
          playable: true,
          rating: track.rating,
          genre: track.pendingRating.isRated() ? track.pendingRating.isThumbUp().toString() : 'null',
          duration: track.duration,
        ),
    ];
  }
}
