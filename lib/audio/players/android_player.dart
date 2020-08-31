import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/audio/players/player.dart';
import 'package:flutter/widgets.dart';
import 'package:qudio/qudio.dart';

class AndroidPlayer extends Player {
  AndroidPlayer({
    @required Function(bool playing) onPlayPauseStateChange,
    @required Function(AudioProcessingState newAudioProcessingState) onAudioProcessingStateChange,
    @required Function(int newQueueSize) onSongAdvancement,
    @required Function(int newDuration) onDurationChange,
    @required VoidCallback onSeek,
    @required VoidCallback onError,
  }) : super(
          onPlayPauseStateChange: onPlayPauseStateChange,
          onAudioProcessingStateChange: onAudioProcessingStateChange,
          onSongAdvancement: onSongAdvancement,
          onDurationChange: onDurationChange,
          onSeek: onSeek,
          onError: onError,
        );

  StreamSubscription<QudioPlaybackStatus> _playbackStatusListener;
  StreamSubscription<PositionDiscontinuityReason> _positionDiscontinuityListener;
  StreamSubscription<bool> _isLoadingListener;
  StreamSubscription<bool> _sourceErrorListener;

  // Initialise the player.
  @override
  void init() {
    Qudio.connect();

    _playbackStatusListener = Qudio.playbackStatusStream.listen((playbackStatus) {
      switch (playbackStatus.playbackState) {
        case QudioPlaybackState.idle:
          onAudioProcessingStateChange(AudioProcessingState.none);
          break;

        case QudioPlaybackState.buffering:
          onAudioProcessingStateChange(AudioProcessingState.buffering);
          break;

        case QudioPlaybackState.ready:
          onPlayPauseStateChange(playbackStatus.playing);
          onAudioProcessingStateChange(AudioProcessingState.ready);
          break;

        case QudioPlaybackState.ended:
          onAudioProcessingStateChange(AudioProcessingState.buffering);
          break;
      }
    });

    _positionDiscontinuityListener = Qudio.positionDiscontinuityStream.listen((reason) async {
      switch (reason) {
        case PositionDiscontinuityReason.periodTransition:
          onSongAdvancement(await Qudio.queueSize);
          break;

        case PositionDiscontinuityReason.seek:
          onSeek();
          break;

        case PositionDiscontinuityReason.seekAdjustment:
          break;

        case PositionDiscontinuityReason.adInsertion:
          break;

        case PositionDiscontinuityReason.internal:
          break;
      }
    });

    _isLoadingListener = Qudio.isLoadingStream.listen((isLoading) async {
      if (!isLoading) onDurationChange(await Qudio.currentDuration);
    });

    _sourceErrorListener = Qudio.sourceErrorStream.listen((hasError) {
      if (hasError) onError();
    });
  }

  // Dispose of the player.
  @override
  Future<void> dispose() async {
    await Future.wait([
      _playbackStatusListener.cancel(),
      _positionDiscontinuityListener.cancel(),
      _isLoadingListener.cancel(),
      _sourceErrorListener.cancel(),
    ]);

    Qudio.disconnect();
  }

  // Unpause the player.
  @override
  void play() => _callIfPlayerReady(Qudio.play);

  // Pause the player.
  @override
  void pause() => _callIfPlayerReady(Qudio.pause);

  // Toggle play/pause in the player.
  @override
  void togglePlayPause() => _callIfPlayerReady(Qudio.playbackStatus.playing ? pause : play);

  // Skip to the next song.
  @override
  void skip() => Qudio.skip;

  // Skip to a particular song.
  @override
  void skipTo(int position) => Qudio.skipTo(position);

  // Fast-forward the given amount of milliseconds.
  @override
  void fastForward(int ms) => _callIfPlayerReady(() => Qudio.fastForward(ms));

  // Rewind the given amount of milliseconds.
  @override
  void rewind(int ms) => _callIfPlayerReady(() => Qudio.rewind(ms));

  // Seek to the point at the given amount of milliseconds.
  @override
  void seekTo(ms) => _callIfPlayerReady(() => Qudio.seekTo(ms));

  // Stop playback, and clear the queue.
  @override
  void stop() => Qudio.stop();

  // Add a URL to the player queue.
  @override
  void addToQueue(String url, bool firstLoad) {
    Qudio.addToQueue(url);
    if (firstLoad) Qudio.begin();
  }

  // Add a list of URLs to the player queue.
  @override
  void addAllToQueue(List<String> urls, bool firstLoad) {
    Qudio.addAllToQueue(urls);
    if (firstLoad) Qudio.begin();
  }

  // Remove a URL from the player queue at the given position.
  @override
  void removeFromQueue(int position) => Qudio.removeFromQueue(position);

  // Get the current playback position.
  @override
  Future<int> getPosition() async => (await Qudio.currentPosition) ?? 0;

  // Get the duration of the playing media.
  @override
  Future<int> getDuration() async => (await Qudio.currentDuration) ?? 0;

  void _callIfPlayerReady(Function function) {
    if (Qudio.playbackStatus.playbackState == QudioPlaybackState.ready) function();
  }
}
