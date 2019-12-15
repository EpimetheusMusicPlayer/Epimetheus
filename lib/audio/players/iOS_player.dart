import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/audio/players/player.dart';
import 'package:flutter/widgets.dart';

class iOSPlayer extends Player {
  iOSPlayer({
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

  @override
  void addToQueue(String url, bool firstLoad) {
    // TODO: implement addToQueue
  }

  @override
  Future<void> dispose() {
    // TODO: implement dispose
    return null;
  }

  @override
  void fastForward(int ms) {
    // TODO: implement fastForward
  }

  @override
  void init() {
    // TODO: implement init
  }

  @override
  void pause() {
    // TODO: implement pause
  }

  @override
  void play() {
    // TODO: implement play
  }

  @override
  void removeFromQueue(int position) {
    // TODO: implement removeFromQueue
  }

  @override
  void rewind(int ms) {
    // TODO: implement rewind
  }

  @override
  void skip() {
    // TODO: implement skip
  }

  @override
  void skipTo(int position) {
    // TODO: implement skipTo
  }

  @override
  void stop() {
    // TODO: implement stop
  }

  @override
  Future<int> getPosition() {
    // TODO: implement getPosition
  }

  @override
  void seekTo(ms) {
    // TODO: implement seekTo
  }

  @override
  void togglePlayPause() {
    // TODO: implement togglePlayPause
  }

  @override
  void addAllToQueue(List<String> urls, bool firstLoad) {
    // TODO: implement addAllToQueue
  }
}
