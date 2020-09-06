// import 'dart:async';
//
// import 'package:audio/audio.dart';
// import 'package:audio_service/audio_service.dart';
// import 'package:epimetheus/audio/players/player.dart';
// import 'package:flutter/widgets.dart';
//
// class iOSPlayer extends Player {
//   iOSPlayer({
//     @required Function(bool playing) onPlayPauseStateChange,
//     @required Function(AudioProcessingState newAudioProcessingState) onAudioProcessingStateChange,
//     @required Function(int newQueueSize) onSongAdvancement,
//     @required Function(int newDuration) onDurationChange,
//     @required VoidCallback onSeek,
//     @required VoidCallback onError,
//   }) : super(
//           onPlayPauseStateChange: onPlayPauseStateChange,
//           onAudioProcessingStateChange: onAudioProcessingStateChange,
//           onSongAdvancement: onSongAdvancement,
//           onDurationChange: onDurationChange,
//           onSeek: onSeek,
//           onError: onError,
//         );
//
//   Audio player;
//   final List<String> queue = [];
//
//   StreamSubscription<AudioPlayerState> _onPlayerStateChangedListener;
//   StreamSubscription<AudioPlayerError> _onPlayerErrorListener;
//
//   // Initialise the player.
//   @override
//   void init() {
//     player = Audio(single: false);
//
//     _onPlayerStateChangedListener = player.onPlayerStateChanged.listen((playerState) {
//       switch (playerState) {
//         case AudioPlayerState.LOADING:
//           onAudioProcessingStateChange(AudioProcessingState.buffering);
//           break;
//
//         case AudioPlayerState.READY:
//           onDurationChange(player.duration);
//           break;
//
//         case AudioPlayerState.PLAYING:
//           onPlayPauseStateChange(true);
//           onAudioProcessingStateChange(AudioProcessingState.ready);
//           break;
//
//         case AudioPlayerState.PAUSED:
//           onPlayPauseStateChange(false);
//           onAudioProcessingStateChange(AudioProcessingState.ready);
//           break;
//
//         case AudioPlayerState.STOPPED:
//           queue.removeAt(0);
//           onAudioProcessingStateChange(AudioProcessingState.buffering);
//           onSongAdvancement(queue.length);
//           break;
//       }
//     });
//
//     _onPlayerErrorListener = player.onPlayerError.listen((error) {
//       onError();
//     });
//   }
//
//   // Dispose of the player.
//   @override
//   Future<void> dispose() async {
//     _onPlayerStateChangedListener.cancel();
//     _onPlayerErrorListener.cancel();
//     player.release();
//   }
//
//   // Unpause the player.
//   @override
//   void play() => _callIfPlayerReady(() => player.play(queue[0]));
//
//   // Pause the player.
//   @override
//   void pause() => _callIfPlayerReady(player.pause);
//
//   // Toggle play/pause in the player.
//   @override
//   void togglePlayPause() {
//     if (player.state == AudioPlayerState.PLAYING)
//       player.pause();
//     else if (player.state == AudioPlayerState.PAUSED) player.play(queue[0]);
//   }
//
//   // Skip to the next song.
//   @override
//   void skip() {
//     queue.removeAt(0);
//     player.play(queue[0]);
//     onSongAdvancement(queue.length);
//   }
//
//   // Skip to a particular song.
//   @override
//   void skipTo(int position) {
//     queue.removeRange(0, position);
//     player.play(queue[0]);
//     onSongAdvancement(queue.length);
//   }
//
//   // Fast-forward the given amount of milliseconds.
//   @override
//   void fastForward(int ms) => _callIfPlayerReady(() => player.seek(0));
//
//   // Rewind the given amount of milliseconds.
//   @override
//   void rewind(int ms) => _callIfPlayerReady(() => player.seek(0));
//
//   // Seek to the point at the given amount of milliseconds.
//   @override
//   void seekTo(ms) => _callIfPlayerReady(() => player.seek(ms));
//
//   // Stop playback, and clear the queue.
//   @override
//   void stop() {
//     queue.clear();
//   }
//
//   // Add a URL to the player queue.
//   @override
//   void addToQueue(String url, bool firstLoad) {
//     queue.add(url);
//     if (firstLoad) {
//       player.play(queue[0]);
//       player.preload(queue[1]);
//     }
//   }
//
//   // Add a list of URLs to the player queue.
//   @override
//   void addAllToQueue(List<String> urls, bool firstLoad) {
//     queue.addAll(urls);
//     if (firstLoad) player.play(queue[0]);
// //    player.preload(queue[1]);
//   }
//
//   // Remove a URL from the player queue at the given position.
//   @override
//   void removeFromQueue(int position) {
//     queue.removeAt(0);
//     if (position == 0) player.play(queue[0]);
//   }
//
//   // Get the current playback position.
//   @override
//   Future<int> getPosition() async => 0; // TODO implement this
//
//   // Get the duration of the playing media.
//   @override
//   Future<int> getDuration() async => player.duration;
//
//   void _callIfPlayerReady(Function function) {
//     if (player.state == AudioPlayerState.READY || player.state == AudioPlayerState.PLAYING || player.state == AudioPlayerState.PAUSED) {
//       function();
//     }
//   }
// }
