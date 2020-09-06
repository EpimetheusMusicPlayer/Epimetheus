import 'dart:collection';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/art_constants.dart';
import 'package:epimetheus/audio/providers/music_provider.dart';
import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:epimetheus/libepimetheus/crypto/xor.dart';
import 'package:epimetheus/libepimetheus/playable_media/playlists.dart';
import 'package:epimetheus/libepimetheus/playable_media/tracks.dart';
import 'package:epimetheus/libepimetheus/playlists.dart';
import 'package:flutter/widgets.dart';

/// Handles playlist media data.
/// A brief overview of Pandora's playlist APIs:
/// Pandora manages state on the server side.
/// v7/playlists/annotatePlaylists receives playlist annotations. A POST body example: {"request":{"pandoraIds":["PL:1970324848814932:1733146208"]}}
/// v1/playback/source tells the server a playlist is going to be played, and receives a url to play.
/// v1/action/skip tells the server the song was skipped, and receives the url of the next song.
/// v1/action/previous does the same, but goes the other direction.
/// v1/playback/peek can be requested at any time to get the next audio url.
/// v1/event/ended lets the server know that a song has ended. Nothing is received when requesting this.
/// v1/playback/current receives the currently playing audio url. The web app uses this after sending event/ended.
/// v1/action/shuffle turns shuffle on or off based on the enabled boolean.
class PlaylistMusicProvider extends MusicProvider {
  final String _pandoraId;
  PlaylistTrackList _trackManager;
  final LinkedHashMap _playableTrackMap = LinkedHashMap<String, PlayableTrack>();

  final _pendingFutures = <Future<dynamic>>[];

  bool _shuffle = true;

  XORDecryptionProxy _proxy;

  PlaylistMusicProvider({
    final PlaylistTrackList trackList,
    final String pandoraId,
  })  : assert(trackList != null || pandoraId != null),
        _trackManager = trackList,
        _pandoraId = pandoraId,
        super(canRateItems: false);

  @override
  Future<bool> init(User user) async {
    _proxy = XORDecryptionProxy()..start();

    if (_trackManager == null) {
      try {
        _trackManager = await Playlist.getTracksFromId(
          pandoraId: _pandoraId,
          user: user,
          limit: 100,
          offset: 0,
          version: 0,
        );

        while (_trackManager.items.length < _trackManager.totalCount) {
          _trackManager += await Playlist.getTracksFromId(
            pandoraId: _pandoraId,
            user: user,
            limit: 100,
            offset: _trackManager.items.length,
            version: _trackManager.version,
          );
        }
      } on SocketException {
        return false;
      }
    }

    final initialTrack = await _trackManager.begin(
      user: user,
      shuffle: _shuffle,
    );

    _playableTrackMap[initialTrack.track.pandoraId] = initialTrack;
    currentQueueIndex = _getNewIndex(initialTrack.track.pandoraId);

    await _peek(user);

    return true;
  }

  @override
  void dispose() {
    _proxy.stop();
  }

  @override
  String get id => _pandoraId;

  @override
  String get title => _trackManager.name;

  // To avoid confusion: this integer represents the index of the currently playing track,
  // in the _trackManager. It is not the same as the index in Pandora API responses.
  @override
  int currentQueueIndex = 0;

  @override
  Future<List<Uri>> prepareSkipTo(User user, String id) async {
    // Note: the index here refers to the index of a track in the _trackManager.
    final index = _getNewIndex(id);

    final newTrack = await _trackManager.begin(
      user: user,
      shuffle: _shuffle,
      index: index,
    );

    // At this point, the old song is still playing. If a new request
    // for the old song media is made after the clear, it could be problematic -
    // but that shouldn't happen.
    _playableTrackMap.clear();
    _proxy.clearUrls();
    _playableTrackMap[newTrack.track.pandoraId] = newTrack;

    currentQueueIndex = index;

    final peekedTrack = await _peek(user);
    return <Uri>[
      _proxy.addUrl(newTrack.audioUrl, newTrack.key),
      _proxy.addUrl(peekedTrack.audioUrl, peekedTrack.key),
    ];
  }

  @override
  Future<List<Uri>> prepareSkip(User user, int oldIndex) async {
    print('PREPARING SKIP');
    await Future.wait<dynamic>(_pendingFutures);

    PlayableTrack newTrack;

    // If a peeked track exists, use it.
    if (_playableTrackMap.length == 2) {
      // Let the server know that the track finished asynchronously.
      _addPendingFuture(_trackManager.notifyEnded(user: user, oldIndex: oldIndex));

      // Use the peeked track.
      newTrack = _playableTrackMap.values.last;
    } else {
      // Tell the server that the track ended.
      await _trackManager.notifyEnded(user: user, oldIndex: oldIndex);

      // Grab the new track.
      newTrack = await _trackManager.current(user: user);
    }

    // Create a list to populate with new URIs and return
    final newURIs = <Uri>[];

    // If the playable track map contains the next key (from peeking),
    // don't overwrite the track object. Otherwise, clear the map and
    // add it.
    // The map is cleared as it's only possible to obtain the URL one
    // place ahead of the currently playing track, so once we skip, no
    // others can be valid.
    final newPandoraId = newTrack.track.pandoraId;
    if (_playableTrackMap.containsKey(newPandoraId)) {
      _playableTrackMap.removeWhere((key, value) => key != newPandoraId);
      _proxy.clearAllExceptUrl(_playableTrackMap[newPandoraId].audioUrl);
    } else {
      _playableTrackMap.clear();
      _proxy.clearUrls();
      _playableTrackMap[newPandoraId] = newTrack;
    }

    // Add the new track URI to the list to be returned.
    newURIs.add(_proxy.addUrl(newTrack.audioUrl + '&name=${newTrack.track.title}', newTrack.key));

    // Peek; grab info for the next upcoming song.
    final peekedTrack = await _peek(user);
    newURIs.add(_proxy.addUrl(peekedTrack.audioUrl + '&name=${newTrack.track.title}', peekedTrack.key));

    // Update the currently playing index.
    currentQueueIndex = _getNewIndex(newPandoraId);

    // Return the new URIs to add.
    return newURIs;
  }

  @override
  Future<void> rate(User user, int index, Rating rating, bool update) async {}

  @override
  void tired(int index) {}

  @override
  Future<List<MediaItem>> load(User user) async {
    return [
      for (final track in _trackManager.items)
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
          duration: track.duration,
        ),
    ];
  }

  @override
  bool shouldLoad() => false; // All data is loaded at once.

  @override
  Uri getAudioUri(int index) {
    final track = _playableTrackMap[_trackManager.items[index].pandoraId];
    if (track == null) return null;
    final uri = _proxy.addUrl(track.audioUrl, track.key);
    print(uri);
    return uri;
  }

  @override
  List<MediaItem> getChildren(String parentId) {
    // TODO implement getChildren()
  }

  @override
  List<MusicProviderAction> getActions(State state) => [];

  Future<T> _addPendingFuture<T>(Future<T> future) async {
    _pendingFutures.add(future);
    final result = await future;
    _pendingFutures.remove(future);
    return result;
  }

  int _getNewIndex(String pandoraId) {
    return _trackManager.items.indexWhere(
      (track) => track.pandoraId == pandoraId,
    );
  }

  Future<PlayableTrack> _peek(User user) async {
    final nextTrack = await _trackManager.peek(user: user);
    _playableTrackMap[nextTrack.track.pandoraId] = nextTrack;
    // return _proxy.addUrl(nextTrack.audioUrl, nextTrack.key);
    return nextTrack;
  }
}
