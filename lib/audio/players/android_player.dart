import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/audio/players/player.dart';
import 'package:flutter/widgets.dart';
import 'package:qudio/qudio.dart';

class AndroidPlayer extends Player {
  AndroidPlayer({
    @required Function(BasicPlaybackState newPlaybackState) onPlaybackStateChange,
    @required Function(int newQueueSize) onSongAdvancement,
    @required VoidCallback onSeek,
    @required VoidCallback onError,
  }) : super(
          onPlaybackStateChange: onPlaybackStateChange,
          onSongAdvancement: onSongAdvancement,
          onSeek: onSeek,
          onError: onError,
        );

  StreamSubscription<QudioPlaybackStatus> _playbackStatusListener;
  StreamSubscription<PositionDiscontinuityReason> _positionDiscontinuityListener;
  StreamSubscription<bool> _sourceErrorListener;

  @override
  void init() {
    Qudio.connect();

    _playbackStatusListener = Qudio.playbackStatusStream.listen((playbackStatus) {
      switch (playbackStatus.playbackState) {
        case QudioPlaybackState.idle:
          onPlaybackStateChange(BasicPlaybackState.none);
          break;

        case QudioPlaybackState.buffering:
          onPlaybackStateChange(BasicPlaybackState.buffering);
          break;

        case QudioPlaybackState.ready:
          onPlaybackStateChange(playbackStatus.playing ? BasicPlaybackState.playing : BasicPlaybackState.paused);
          break;

        case QudioPlaybackState.ended:
          onPlaybackStateChange(BasicPlaybackState.none);
          break;
      }
    });

    _positionDiscontinuityListener = Qudio.positionDiscontinuityStream.listen((PositionDiscontinuityReason reason) async {
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

    _sourceErrorListener = Qudio.sourceErrorStream.listen((hasError) {
      if (hasError) onError();
    });
  }

  @override
  Future<void> dispose() async {
    await Future.wait([
      _playbackStatusListener.cancel(),
      _positionDiscontinuityListener.cancel(),
      _sourceErrorListener.cancel(),
    ]);

    Qudio.disconnect();
  }

  @override
  void play() => _callIfPlayerReady(Qudio.play);

  @override
  void pause() => _callIfPlayerReady(Qudio.pause);

  @override
  void togglePlayPause() => Qudio.playbackStatus.playing ? pause() : play();

  @override
  void skip() => _callIfPlayerReady(Qudio.skip);

  @override
  void skipTo(int position) => _callIfPlayerReady(() => Qudio.skipTo(position));

  @override
  void fastForward(int ms) => _callIfPlayerReady(() => Qudio.fastForward(ms));

  @override
  void rewind(int ms) => _callIfPlayerReady(() => Qudio.rewind(ms));

  @override
  void seekTo(ms) => _callIfPlayerReady(() => Qudio.seekTo(ms));

  @override
  void stop() => Qudio.stop();

  @override
  void addToQueue(String url, bool firstLoad) {
    Qudio.addToQueue(url);
    if (firstLoad) Qudio.begin();
  }

  @override
  void addAllToQueue(List<String> urls, bool firstLoad) {
    Qudio.addAllToQueue(urls);
    if (firstLoad) Qudio.begin();
  }

  @override
  void removeFromQueue(int position) => Qudio.removeFromQueue(position);

  @override
  Future<int> getPosition() => Qudio.currentPosition;

  void _callIfPlayerReady(Function function) {
    if (Qudio.playbackStatus.playbackState == QudioPlaybackState.ready) function();
  }
}
