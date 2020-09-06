import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/audio/providers/music_provider.dart';
import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:epimetheus/libepimetheus/networking.dart';
import 'package:just_audio/just_audio.dart';

final _usesIsolate = AudioService.usesIsolate;
final _nonIsolatePayloadStreamController = _usesIsolate ? null : StreamController<dynamic>.broadcast();

class _AudioTaskPayload {
  final User user;
  final MusicProvider musicProvider;
  final String csrfToken;

  _AudioTaskPayload({
    this.user,
    this.musicProvider,
    this.csrfToken,
  });
}

// Only to be invoked from the UI isolate.
Future<void> launchMusicProvider(User user, MusicProvider musicProvider) async {
  final wasConnected = AudioService.connected;

  assert(user != null, 'User is null!');
  assert(musicProvider != null, 'MusicProvider is null!');

  if (!wasConnected) await AudioService.connect();

  await AudioService.start(
    backgroundTaskEntrypoint: audioTaskEntryPoint,
    androidEnableQueue: true,
    androidNotificationIcon: 'mipmap/ic_launcher_foreground',
    androidNotificationChannelName: 'Media',
    androidNotificationChannelDescription: 'Media information and controls',
    androidNotificationOngoing: true,
  );

  if (!wasConnected) AudioService.disconnect();

  (AudioService.usesIsolate ? IsolateNameServer.lookupPortByName('audio_task')?.send : _nonIsolatePayloadStreamController.add)(
    _AudioTaskPayload(
      user: user,
      musicProvider: musicProvider,
      csrfToken: csrfToken,
    ),
  );
}

void audioTaskEntryPoint() => AudioServiceBackground.run(() => _AudioTask());

class _AudioTask extends BackgroundAudioTask {
  User _user;
  MusicProvider _musicProvider;

  final ReceivePort _receivePort = ReceivePort();

  final List<MediaControl> _mediaControls = <MediaControl>[
    const MediaControl(label: 'Stop', androidIcon: 'drawable/ic_stop', action: MediaAction.stop),
    const MediaControl(label: 'Rewind', androidIcon: 'drawable/ic_rewind', action: MediaAction.rewind),
    null,
    const MediaControl(label: 'Fast-forward', androidIcon: 'drawable/ic_fast_forward', action: MediaAction.fastForward),
    const MediaControl(label: 'Skip', androidIcon: 'drawable/ic_skip', action: MediaAction.skipToNext),
  ];

  final _player = AudioPlayer();
  ConcatenatingAudioSource _playerAudioSource;

  StreamSubscription<dynamic> _payloadSubscription;

  StreamSubscription<int> _playerCurrentIndexSubscription;
  StreamSubscription<bool> _playerPlayingSubscription;
  StreamSubscription<ProcessingState> _playerProcessingStateSubscription;
  StreamSubscription<bool> _playerPlayingStateSubscription;

  _AudioTask() {
    if (_usesIsolate) IsolateNameServer.registerPortWithName(_receivePort.sendPort, 'audio_task');
    _payloadSubscription = (AudioService.usesIsolate ? _receivePort : _nonIsolatePayloadStreamController.stream).listen((payload) {
      assert(payload is _AudioTaskPayload);
      launchPayload(payload);
    });
  }

  Future<void> _loadNextPage() async {
    if (AudioServiceBackground.queue == null)
      AudioServiceBackground.setQueue(
        [],
        preloadArtwork: false,
      );

    final existingQueueSize = AudioServiceBackground.queue.length;

    // Set the queue, used by Android Auto and some custom ROMs.
    AudioServiceBackground.setQueue(
      AudioServiceBackground.queue + await _musicProvider.load(_user),
      preloadArtwork: true,
    );

    // Add the new URLs to the player.
    final newQueueSize = AudioServiceBackground.queue.length;

    final audioSources = <ProgressiveAudioSource>[];
    for (var i = existingQueueSize; i < newQueueSize; ++i) {
      final uri = _musicProvider.getAudioUri(i);
      if (uri == null) continue;
      audioSources.add(ProgressiveAudioSource(uri));
    }
    if (_playerAudioSource == null) {
      _playerAudioSource = ConcatenatingAudioSource(children: audioSources);
    } else {
      _playerAudioSource.addAll(audioSources);
    }
  }

  void _updateMetadata() {
    AudioServiceBackground.setMediaItem(AudioServiceBackground.queue[_musicProvider.currentQueueIndex]);
  }

  // A function to update the playback state, used by the system.
  Future<void> _updatePlaybackState(AudioProcessingState processingState, bool playing) async {
    return AudioServiceBackground.setState(
      controls: _mediaControls,
      systemActions: const [MediaAction.seekTo],
      androidCompactActions: const <int>[2, 3, 4],
      processingState: processingState,
      playing: playing,
      position: _player.position,
      updateTime: Duration(milliseconds: DateTime.now().millisecondsSinceEpoch),
      speed: 1,
    );
  }

  // A function to toggle the play/pause button in the media notification controls.
  void _togglePlayPauseControl(bool playing) {
    _mediaControls[2] = playing
        ? const MediaControl(
            label: 'Pause',
            androidIcon: 'drawable/ic_pause',
            action: MediaAction.pause,
          )
        : const MediaControl(
            label: 'Play',
            androidIcon: 'drawable/ic_play',
            action: MediaAction.play,
          );
  }

  void _cancelPlayerStreamSubscriptions() {
    _playerCurrentIndexSubscription?.cancel();
    _playerPlayingSubscription?.cancel();
    _playerProcessingStateSubscription?.cancel();
    _playerPlayingStateSubscription?.cancel();
  }

  Future<void> launchPayload(_AudioTaskPayload payload) async {
    // Set the user to authenticate load requests
    _user = payload.user;

    // Check that the given music provider isn't already playing
    if (_musicProvider != payload.musicProvider) {
      // Show a loading notification
      AudioServiceBackground.setMediaItem(
        const MediaItem(
          id: 'loading',
          title: 'Loading...',
          artist: 'Loading...',
          album: 'Loading...',
          displayTitle: 'Loading...',
          displaySubtitle: 'Loading...',
          displayDescription: '',
          playable: false,
        ),
      );

      // Initialise the new music provider.
      await payload.musicProvider.init(_user);

      // Clear existing metadata if an old provider exists
      if (_musicProvider != null) {
        // Cancel all streams
        _cancelPlayerStreamSubscriptions();

        // Pause playback
        _player.pause();

        // Clear the audio source
        _playerAudioSource = null;

        // Dispose of the old provider
        _musicProvider.dispose();

        // Clear the queue
        AudioServiceBackground.setQueue([], preloadArtwork: false);
      }

      // Set the new music provider
      _musicProvider = payload.musicProvider;

      // Load the first page
      await _loadNextPage();

      // Load the audio source
      _player.load(_playerAudioSource);

      // Update the session metadata
      _updateMetadata();

      // Listen to status streams
      _playerCurrentIndexSubscription = _player.currentIndexStream.listen((currentIndex) async {
        if (currentIndex == null || currentIndex == _musicProvider.currentQueueIndex) return;

        // TODO handle cases where the playlist has no more media

        await _musicProvider.notifySkipTo(currentIndex);
        _updateMetadata();
        _updatePlaybackState(AudioServiceBackground.state.processingState, AudioServiceBackground.state.playing);
        if (_musicProvider.shouldLoad()) _loadNextPage();
      });

      _playerPlayingSubscription = _player.playingStream.listen((playing) {
        _togglePlayPauseControl(playing);
      });

      _playerProcessingStateSubscription = _player.processingStateStream.listen((processingState) {
        final playing = _player.playing;
        switch (processingState) {
          case ProcessingState.none:
            _updatePlaybackState(AudioProcessingState.none, playing);
            break;
          case ProcessingState.loading:
            _updatePlaybackState(AudioProcessingState.buffering, playing);
            break;
          case ProcessingState.buffering:
            _updatePlaybackState(AudioProcessingState.buffering, playing);
            break;
          case ProcessingState.ready:
            _updatePlaybackState(AudioProcessingState.ready, playing);
            break;
          case ProcessingState.completed:
            _updatePlaybackState(AudioProcessingState.completed, playing);
            break;
        }
      });

      _playerPlayingStateSubscription = _player.playingStream.listen((playing) {
        _updatePlaybackState(AudioServiceBackground.state.processingState, playing);
      });

      // Start the player.
      await _player.play();
    }
  }

  @override
  Future<void> onStop() async {
    // Shut down the nameserver port used to receive music providers
    _payloadSubscription?.cancel();
    if (_usesIsolate) IsolateNameServer.removePortNameMapping('audio_task');

    // Cancel all stream subscriptions
    _cancelPlayerStreamSubscriptions();

    // Stop and dispose the player
    await _player.stop();
    await _player.dispose();

    // Dispose of the MusicProvider, if there is one.
    _musicProvider?.dispose();

    // Update the playback state to indicate that the service is stopped
    await _updatePlaybackState(AudioProcessingState.completed, false);

    // Stop the service
    await super.onStop();
  }

  @override
  Future<void> onPlay() async => _player.play();

  @override
  Future<void> onPause() async => _player.pause();

  @override
  Future<void> onSkipToNext() async {
    final newUris = await _musicProvider.prepareSkip(_user, _player.currentIndex);
    if (newUris.isNotEmpty) _playerAudioSource.addAll([for (final uri in newUris) ProgressiveAudioSource(uri)]);
    return _player.seekToNext();
  }

  @override
  Future<void> onSkipToQueueItem(String mediaId) async {
    final newUris = await _musicProvider.prepareSkipTo(_user, mediaId);
    if (newUris.isNotEmpty) _playerAudioSource.addAll([for (final uri in newUris) ProgressiveAudioSource(uri)]);
    return _player.seek(Duration.zero, index: AudioServiceBackground.queue.indexWhere((mediaItem) => mediaItem.id == mediaId));
  }

  @override
  Future<void> onFastForward() async => _player.seek(_player.position + fastForwardInterval);

  @override
  Future<void> onRewind() async => _player.seek(_player.position - rewindInterval);

  @override
  Future<void> onSeekTo(Duration duration) async => _player.seek(duration);

  @override
  Future<void> onSetRating(Rating rating, Map extras) async {
    // TODO: implement onSetRating
    super.onSetRating(rating, extras);
  }

  // Handle button presses from bluetooth or wired devices.
  @override
  Future<void> onClick(MediaButton button) async {
    switch (button) {
      case MediaButton.media:
        if (_player.playing)
          await _player.pause();
        else
          await _player.play();
        break;

      case MediaButton.next:
        onSkipToNext();
        break;

      case MediaButton.previous:
        break;
    }
  }
}
