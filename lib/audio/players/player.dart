import 'package:audio_service/audio_service.dart';
import 'package:flutter/widgets.dart';

abstract class Player {
  final Function(BasicPlaybackState newPlaybackState) onPlaybackStateChange;
  final Function(int newQueueSize) onSongAdvancement;
  final VoidCallback onSeek;
  final VoidCallback onError;

  Player({
    @required this.onPlaybackStateChange,
    @required this.onSongAdvancement,
    @required this.onSeek,
    @required this.onError,
  });

  void init();

  Future<void> dispose();

  void play();

  void pause();

  void togglePlayPause();

  void skip();

  void skipTo(int position);

  void fastForward(int ms);

  void rewind(int ms);

  void seekTo(ms);

  void stop();

  void addToQueue(String url, bool firstLoad);

  void addAllToQueue(List<String> urls, bool firstLoad);

  void removeFromQueue(int position);

  Future<int> getPosition();
}
