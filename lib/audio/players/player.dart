import 'package:audio_service/audio_service.dart';
import 'package:flutter/widgets.dart';

abstract class Player {
  final Function(bool playing) onPlayPauseStateChange;
  final Function(AudioProcessingState newAudioProcessingState) onAudioProcessingStateChange;
  final Function(int newQueueSize) onSongAdvancement;
  final Function(int newDuration) onDurationChange;
  final VoidCallback onSeek;
  final VoidCallback onError;

  Player({
    @required this.onPlayPauseStateChange,
    @required this.onAudioProcessingStateChange,
    @required this.onSongAdvancement,
    @required this.onDurationChange,
    @required this.onSeek,
    @required this.onError,
  });

  // Initialise the player.
  void init();

  // Dispose of the player.
  Future<void> dispose();

  // Unpause the player.
  void play();

  // Pause the player.
  void pause();

  // Toggle play/pause in the player.
  void togglePlayPause();

  // Skip to the next song.
  void skip();

  // Skip to a particular song.
  void skipTo(int position);

  // Fast-forward the given amount of milliseconds.
  void fastForward(int ms);

  // Rewind the given amount of milliseconds.
  void rewind(int ms);

  // Seek to the point at the given amount of milliseconds.
  void seekTo(ms);

  // Stop playback, and clear the queue.
  void stop();

  // Add a URL to the player queue.
  void addToQueue(String url, bool firstLoad);

  // Add a list of URLs to the player queue.
  void addAllToQueue(List<String> urls, bool firstLoad);

  // Remove a URL from the player queue at the given position.
  void removeFromQueue(int position);

  // Get the current playback position.
  Future<int> getPosition();

  // Get the duration of the playing media, in milliseconds.
  Future<int> getDuration();
}
