import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/features/playback/entities/audio_task_actions.dart';
import 'package:epimetheus/features/playback/entities/audio_task_events.dart';
import 'package:epimetheus/features/playback/entities/audio_task_keys.dart';
import 'package:epimetheus/features/playback/services/audio_task/audio_task_communicator.dart';
import 'package:epimetheus/features/playback/services/audio_task/media_sources/media_source.dart';
import 'package:epimetheus/logging.dart';
import 'package:flutter/foundation.dart';
import 'package:iapetus/iapetus.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:pedantic/pedantic.dart';

/// This payload contains information required by the [AudioTask] to begin
/// playback.
///
/// It must be compatible with the [SendPort.send] requirements.
class _AudioTaskPayload {
  final MediaSource mediaSource;
  final Iapetus iapetus;

  /// Constructs the payload.
  ///
  /// The given [iapetus] should be a copy of the original, as properties are
  /// changed by the [AudioTask].
  _AudioTaskPayload({
    required this.mediaSource,
    required this.iapetus,
  });
}

/// Starts the audio task. To be used only as an argument to
/// [AudioService.start].
void _backgroundTaskEntrypoint() =>
    AudioServiceBackground.run(() => AudioTask._());

class AudioTask extends BackgroundAudioTask {
  /// The first media item published, used to convey loading status, has this
  /// ID.
  static const loadingMediaItemId = 'loading';

  // * Media source
  late Iapetus _iapetus;
  MediaSource? _mediaSource;
  Future<List<MediaItem>>? _loadFuture;
  bool _isLoadingForSkip = false;

  // * Audio player
  final _player = AudioPlayer();
  ConcatenatingAudioSource? _playerQueue;
  StreamSubscription<int>? _playerCurrentIndexSubscription;
  StreamSubscription<bool>? _playerPlayingSubscription;
  StreamSubscription<ProcessingState>? _playerProcessingStateSubscription;
  StreamSubscription<int>? _playerAndroidAudioSessionIdSubscription;

  static bool get broadcastMediaSessionId => !kIsWeb && Platform.isAndroid;

  // * Communication
  late StreamSubscription<dynamic> _communicatorSubscription;
  final logger = createLogger('[API (AUDIO_TASK)]');

  // Notification media control properties.
  static const _androidCompactActions = [2, 3, 4];
  final List<MediaControl?> _mediaControls = <MediaControl?>[
    const MediaControl(
      label: 'Stop',
      androidIcon: 'drawable/ic_stop',
      action: MediaAction.stop,
    ),
    const MediaControl(
      label: 'Rewind',
      androidIcon: 'drawable/ic_rewind',
      action: MediaAction.rewind,
    ),
    const MediaControl(
      label: 'Pause',
      androidIcon: 'drawable/ic_pause',
      action: MediaAction.pause,
    ),
    const MediaControl(
      label: 'Fast-forward',
      androidIcon: 'drawable/ic_fast_forward',
      action: MediaAction.fastForward,
    ),
    const MediaControl(
      label: 'Skip',
      androidIcon: 'drawable/ic_skip',
      action: MediaAction.skipToNext,
    ),
  ];

  AudioTask._() {
    // Listen to payloads sent via the communicator.
    _communicatorSubscription = AudioTaskCommunicator.register().listen(
      (payload) {
        // Nothing other than _AudioTaskPayload objects should ever be received
        // here.
        assert(payload is _AudioTaskPayload);

        // Launch the received payload.
        _launchPayload(payload);
      },
    );
  }

  /// Launches the audio task with the given media source and [Iapetus].
  static Future<void> launchMediaSource(
    MediaSource source,
    Iapetus iapetus,
  ) async {
    // Record the initial connection state, to be restored after starting the
    // task.
    final wasConnected = AudioService.connected;

    // Ensure that the service is connected.
    if (!wasConnected) await AudioService.connect();

    // Start the service.
    await AudioService.start(
      backgroundTaskEntrypoint: _backgroundTaskEntrypoint,
      androidEnableQueue: true,
      androidNotificationIcon: 'mipmap/ic_launcher_foreground',
      androidNotificationChannelName: 'Media',
      androidNotificationChannelDescription: 'Media information and controls',
      androidNotificationOngoing: true,
    );

    // Restore the previous connection state.
    if (!wasConnected) await AudioService.disconnect();

    // Send a payload containing the media source and Iapetus to the task.
    AudioTaskCommunicator.add(
      _AudioTaskPayload(
        mediaSource: source,
        iapetus: iapetus.compacted,
      ),
    );
  }

  /// Launches the given payload.
  Future<void> _launchPayload(_AudioTaskPayload payload) async {
    // Set the Iapetus, to be used for API calls.
    // Recreate the logger, as it would have been discarded before sending.
    // Disables reauthentication; the task will stop itself instead, or else the
    // new session will differ from the UI's new session.
    _iapetus = payload.iapetus
      ..logger =
          ((level, messageBuilder) => logger.log(level, messageBuilder()))
      ..reauthenticate = false;

    // Detect if an old media source exists - is this the first launch?
    final hasOldMediaSource = _mediaSource != null;

    // If the given media source is identical to the currently playing one, stop
    // here.
    if (hasOldMediaSource && payload.mediaSource.id == _mediaSource!.id) return;

    // Send an initial media item to the service to convey the loading status.
    unawaited(AudioServiceBackground.setMediaItem(
      MediaItem(
        id: loadingMediaItemId,
        title: 'Loading...',
        artist: 'Loading...',
        album: 'Loading...',
        displayTitle: 'Loading...',
        displaySubtitle: 'Loading...',
        displayDescription: '',
        playable: false,
        extras: {
          AudioTaskMetadataKeys.mediaSourceId: payload.mediaSource.id,
          AudioTaskMetadataKeys.currentlyPlayingQueueIndex: 0,
        },
      ),
    ));

    // Set the service state to playing to show the loading notification.
    await AudioServiceBackground.setState(
      controls: const [],
      processingState: AudioProcessingState.buffering,
      playing: true,
    );

    // Initialize the media source.
    // TODO(optimisation) can this be made to happen as the old data is cleared simultaneously?
    await payload.mediaSource.init(_iapetus);

    // If an existing media provider exists, clear out everything.
    if (hasOldMediaSource) {
      // Pause playback.
      unawaited(_player.pause());

      // Cancel all player-related subscriptions.
      _cancelPlayerEventSubscriptions();

      // Clear the player queue.
      _playerQueue = null;

      // Dispose of the old media source.
      _mediaSource!.dispose();
    }

    // Set the audio service's queue to an empty list.
    await AudioServiceBackground.setQueue(const [], preloadArtwork: false);

    // Set the new media source.
    _mediaSource = payload.mediaSource;

    // Load the first page of media.
    await _loadNextPage(true);

    // Load the player audio source.
    await _player.load(_playerQueue);

    // Update the service metadata.
    _updateMetadata();

    // Listen to player events.
    _listenToPlayerEvents();

    // Start the player.
    await _player.play();
  }

  /// Loads the next page of media, provided by the media source.
  Future<void> _loadNextPage([bool initialLoad = false]) async {
    // Don't load multiple pages at once.
    if (_loadFuture != null) {
      // Catch all errors here; they're dealt with in the load function.
      await _loadFuture!.catchError((e) {});
      return;
    }

    try {
      // Record the existing audio service queue size, used later in calculations.
      final oldQueueSize = AudioServiceBackground.queue.length;

      // Load the next page of media from the source.
      // TODO(fix) background task load error handling?
      _loadFuture = _mediaSource!.load(_iapetus, initialLoad);
      final nextPage = await _loadFuture!;

      // Set the audio service queue.
      await AudioServiceBackground.setQueue(
        AudioServiceBackground.queue + nextPage,
        preloadArtwork: true,
      );

      // Add the new URLs to the player.
      // Create a list of player audio sources with URIs provided by the media
      // source.
      final newAudioSources = [
        for (var i = oldQueueSize; i < AudioServiceBackground.queue.length; ++i)
          ProgressiveAudioSource(_mediaSource!.getAudioUri(i)),
      ];

      // Add the new player sources to the player.
      // Normally, the player would never be null, and just be empty at times.
      // This cannot be done, however, due to this bug:
      // https://github.com/ryanheise/just_audio/issues/177
      if (_playerQueue == null) {
        _playerQueue = ConcatenatingAudioSource(children: newAudioSources);
      } else {
        await _playerQueue!.addAll(newAudioSources);
      }
    } on MediaSourceLoadException catch (e) {
      logger.log(
          Level.warning, 'Stopping audio task; load error: (${e.inner}.');
      await AudioService.stop();
    } on InvalidatedMediaSourceSessionException {
      logger.log(Level.warning, 'Stopping audio task; session invalidated.');
      await AudioService.stop();
    } finally {
      _loadFuture = null;
    }
  }

  /// Prepares for a skip.
  ///
  /// Ensures that media exists at the given index.
  /// May stop the service if no media exists.
  ///
  /// Returns true if the callee should proceed to skip, and false if it
  /// shouldn't (when a skip is already in progress).
  Future<bool> _prepareForSkip(int index) async {
    if (index >= AudioServiceBackground.queue.length) {
      if (_isLoadingForSkip) return false;
      _isLoadingForSkip = true;
      await _loadNextPage();
      _isLoadingForSkip = false;
    }
    return true;
  }

  /// Synchronises the audio service metadata with the currently playing
  /// queue item.
  void _updateMetadata() {
    final index = _mediaSource!.currentQueueIndex;
    AudioServiceBackground.setMediaItem(
      AudioServiceBackground.queue[index].copyWith(
        extras: {
          AudioTaskMetadataKeys.mediaSourceId: _mediaSource!.id,
          AudioTaskMetadataKeys.currentlyPlayingQueueIndex: index,
        },
      ),
    );
  }

  /// Updates the play or pause control in the media control list.
  /// Does not notify the service of the change; this must be done manually.
  void _togglePlayPauseControl(bool isPlaying) {
    _mediaControls[2] = isPlaying
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

  /// Sets the service's recorded playback state to the given state.
  Future<void> _updatePlaybackState(
    AudioProcessingState processingState,
    bool isPlaying,
  ) async {
    await AudioServiceBackground.setState(
      controls: _mediaControls,
      systemActions: const [MediaAction.seekTo],
      androidCompactActions: _androidCompactActions,
      processingState: processingState,
      playing: isPlaying,
      position: _player.position,
    );
  }

  void _listenToPlayerEvents() {
    _playerCurrentIndexSubscription = _player.currentIndexStream.listen(
      (int? index) async {
        // Sometimes, the index can be null. Ignore it if it is.
        if (index == null) return;

        // Assert that the player's new index is smaller than the length of the
        // queue.
        assert(
          index < AudioServiceBackground.queue.length,
          'Player skipped with nothing to skip to!',
        );

        // Update the player volume to match the song.
        unawaited(_player.setVolume(_mediaSource!.getVolumeFor(index) * 0.5));

        // If the index hasn't changed, stop here.
        if (index == _mediaSource!.currentQueueIndex) return;

        // Notify the media source of the index change.
        _mediaSource!.notifySkipTo(index);

        // Update the service's metadata.
        _updateMetadata();

        // Update the service's playback state.
        await _updatePlaybackState(
          AudioServiceBackground.state.processingState,
          AudioServiceBackground.state.playing,
        );

        // Load the next page, if necessary.
        if (_mediaSource!.shouldLoad) await _loadNextPage();
      },
    );

    _playerPlayingSubscription = _player.playingStream.listen(
      (isPlaying) {
        _togglePlayPauseControl(isPlaying);
        _updatePlaybackState(
          AudioServiceBackground.state.processingState,
          isPlaying,
        );
      },
    );

    _playerProcessingStateSubscription = _player.processingStateStream.listen(
      (processingState) {
        final isPlaying = _player.playing;
        switch (processingState) {
          case ProcessingState.none:
            _updatePlaybackState(AudioProcessingState.none, isPlaying);
            break;
          case ProcessingState.loading:
            _updatePlaybackState(AudioProcessingState.buffering, isPlaying);
            break;
          case ProcessingState.buffering:
            _updatePlaybackState(AudioProcessingState.buffering, isPlaying);
            break;
          case ProcessingState.ready:
            _updatePlaybackState(AudioProcessingState.ready, isPlaying);
            break;
          case ProcessingState.completed:
            _updatePlaybackState(AudioProcessingState.completed, isPlaying);
            break;
        }
      },
    );

    if (broadcastMediaSessionId) {
      _playerAndroidAudioSessionIdSubscription =
          _player.androidAudioSessionIdStream.listen(
        (id) {
          AudioServiceBackground.sendCustomEvent(
            AndroidAudioSessionIdChanged(id),
          );
        },
      );
    }
  }

  void _cancelPlayerEventSubscriptions() {
    _playerCurrentIndexSubscription?.cancel();
    _playerPlayingSubscription?.cancel();
    _playerProcessingStateSubscription?.cancel();
    if (broadcastMediaSessionId) {
      _playerAndroidAudioSessionIdSubscription?.cancel();
    }
  }

  @override
  Future<void> onStop() async {
    // Cancel player subscriptions.
    _cancelPlayerEventSubscriptions();

    // Shut down communications.
    await _communicatorSubscription.cancel();
    AudioTaskCommunicator.unregister();

    // Stop and dispose of the player.
    await _player.stop();
    await _player.dispose();

    // Dispose of the media source.
    _mediaSource!.dispose();

    // Update the service's playback state to indicate completion.
    await _updatePlaybackState(AudioProcessingState.completed, false);

    // Finally, stop the service.
    await super.onStop();
  }

  @override
  Future<void> onPlay() => _player.play();

  @override
  Future<void> onPause() => _player.pause();

  @override
  Future<void> onSkipToNext() async {
    if (await _prepareForSkip(_mediaSource!.currentQueueIndex + 1)) {
      // TODO(fix) this should skip once the next page is loaded, but it doesn't.
      // Work out why.
      await _player.seekToNext();
    }
  }

  @override
  // TODO(test) test this function (onSkipToQueueItem)
  Future<void> onSkipToQueueItem(String mediaId) async {
    final queue = AudioServiceBackground.queue;
    for (var i = 0; i < queue.length; ++i) {
      if (queue[i].id == mediaId && i > _mediaSource!.currentQueueIndex) {
        if (await _prepareForSkip(i)) {
          await _player.seek(Duration.zero, index: i);
        }
        break;
      }
    }
  }

  @override
  Future<void> onFastForward() =>
      _player.seek(_player.position + fastForwardInterval);

  @override
  Future<void> onRewind() => _player.seek(_player.position - rewindInterval);

  @override
  Future<void> onSeekTo(Duration position) => _player.seek(position);

  // TODO(feature) rating

  @override
  Future<void> onClick(MediaButton button) async {
    switch (button) {
      case MediaButton.media:
        await (_player.playing ? _player.pause() : _player.play());
        break;

      case MediaButton.next:
        await onSkipToNext();
        break;

      case MediaButton.previous:
        break;
    }
  }

  @override
  Future<dynamic> onCustomAction(String name, arguments) async {
    switch (name) {
      case AudioTaskActions.getAndroidAudioSessionId:
        assert(broadcastMediaSessionId,
            'Can only get android session ID on some platforms!');
        return _player.androidAudioSessionId;
      default:
        throw UnsupportedError('Custom action $name is not known!');
    }
  }

  @override
  Future<void> onTaskRemoved() => onStop();
}
