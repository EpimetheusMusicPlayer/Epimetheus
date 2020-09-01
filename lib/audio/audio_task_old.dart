import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/audio/players/android_player.dart';
import 'package:epimetheus/audio/players/iOS_player.dart';
import 'package:epimetheus/audio/players/player.dart';
import 'package:epimetheus/audio/providers/music_provider.dart';
import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:epimetheus/libepimetheus/networking.dart';
import 'package:meta/meta.dart';

class _AudioTaskPayload {
  final User user;
  final MusicProvider musicProvider;
  final String csrfToken;

  _AudioTaskPayload({
    @required this.user,
    @required this.musicProvider,
    @required this.csrfToken,
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

  IsolateNameServer.lookupPortByName('audio_task')?.send(
    _AudioTaskPayload(
      user: user,
      musicProvider: musicProvider,
      csrfToken: csrfToken,
    ),
  );
}

void audioTaskEntryPoint() => AudioServiceBackground.run(() => EpimetheusAudioTask());

class EpimetheusAudioTask extends BackgroundAudioTask {
  Completer<void> serviceCompleter = Completer<void>();

  User user;
  MusicProvider musicProvider;

  final ReceivePort receivePort = ReceivePort();

  final List<MediaControl> mediaControls = <MediaControl>[
    const MediaControl(label: 'Stop', androidIcon: 'drawable/ic_stop', action: MediaAction.stop),
    const MediaControl(label: 'Rewind', androidIcon: 'drawable/ic_rewind', action: MediaAction.rewind),
    null,
    const MediaControl(label: 'Fast-forward', androidIcon: 'drawable/ic_fast_forward', action: MediaAction.fastForward),
    const MediaControl(label: 'Skip', androidIcon: 'drawable/ic_skip', action: MediaAction.skipToNext),
  ];

  Player player;

  EpimetheusAudioTask() {
    IsolateNameServer.registerPortWithName(receivePort.sendPort, 'audio_task');

    void onPlayPauseStateChange(bool playing) {
      togglePlayPauseControl(playing);
    }

    void onAudioProcessingStateChange(AudioProcessingState newAudioProcessingState) {
      switch (newAudioProcessingState) {
        case AudioProcessingState.buffering:
        case AudioProcessingState.ready:
          updatePlaybackState(newAudioProcessingState);
          break;

        case AudioProcessingState.none:
        case AudioProcessingState.stopped:
        case AudioProcessingState.fastForwarding:
        case AudioProcessingState.rewinding:
        case AudioProcessingState.error:
        case AudioProcessingState.connecting:
        case AudioProcessingState.skippingToPrevious:
        case AudioProcessingState.skippingToNext:
        case AudioProcessingState.skippingToQueueItem:
        case AudioProcessingState.completed:
          break;
      }
    }

    // Called when the player advances to a new song
    void onSongAdvancement(int newQueueSize) async {
      final count = musicProvider.count;

      // Load more songs, and wait till they're loaded as there are no more loaded songs to play
      if (newQueueSize == 0) await load(true);

      // Load more songs asynchronously when there are just two loaded songs left so there's not
      // a long wait to play the next batch of songs.
      if (newQueueSize == 2) load(false);

      musicProvider.skipTo(count - newQueueSize);
      updateCurrentMediaInfo(true);
    }

    // Called when the duration of the playing song may have changed
    void onDurationChange(int duration) {
      updateCurrentMediaInfo(false);
    }

    // Called when the player encounters an error (most likely due to network connectivity)
    void onError() {
      onStop();
    }

    // Instantiate the appropriate player depending on the platform
    if (Platform.isAndroid)
      player = AndroidPlayer(
        onPlayPauseStateChange: onPlayPauseStateChange,
        onAudioProcessingStateChange: onAudioProcessingStateChange,
        onSongAdvancement: onSongAdvancement,
        onDurationChange: onDurationChange,
        onError: onError,
        onSeek: () {},
      );
    else if (Platform.isIOS)
      player = iOSPlayer(
        onPlayPauseStateChange: onPlayPauseStateChange,
        onAudioProcessingStateChange: onAudioProcessingStateChange,
        onSongAdvancement: onSongAdvancement,
        onDurationChange: onDurationChange,
        onError: onError,
        onSeek: () {},
      );
    else
      throw Exception('Unsupported platform!');

    // Wait for the music provider to be sent to the service isolate
    receivePort.listen((payload) async {
      if (payload is _AudioTaskPayload) {
        // Set the user to authenticate load requests
        user = payload.user;

        // Copy the csrfToken so it's faster to make the first network request
        csrfToken = payload.csrfToken;

        // Check that the given music provider isn't already playing
        if (musicProvider != payload.musicProvider) {
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

          // Initialise the music provider.
          payload.musicProvider.init();

          // Stop the player to play the new media
          player.stop();

          // Change the playback states and notification play/pause button
          togglePlayPauseControl(true);
          updatePlaybackState(AudioProcessingState.buffering);

          // Set the new music provider
          musicProvider = payload.musicProvider;

          // Load the first songs, and start media playback
          await load(true);

          // Update the media metadata
          updateCurrentMediaInfo(true);
        }
      }
    });
  }

  // A function to toggle the play/pause button in the media notification controls.
  void togglePlayPauseControl(bool playing) {
    mediaControls[2] = playing
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

  // A function to update the playback state, used by the system.
  Future<void> updatePlaybackState(AudioProcessingState processingState) async {
    return AudioServiceBackground.setState(
      controls: mediaControls,
      systemActions: const [MediaAction.seekTo],
      androidCompactActions: const <int>[2, 3, 4],
      processingState: processingState,
      playing: AudioServiceBackground.state.playing,
      position: Duration(milliseconds: await player.getPosition()),
      updateTime: Duration(milliseconds: DateTime.now().millisecondsSinceEpoch),
      speed: 1,
    );
  }

  @override
  Future<void> onStart(Map<String, dynamic> params) async {
    // Initialise the audio player
    player.init();
  }

  // Handle button presses from bluetooth or wired devices.
  @override
  Future<void> onClick(MediaButton button) async {
    switch (button) {
      case MediaButton.media:
        player.togglePlayPause();
        break;

      case MediaButton.next:
        player.skipTo(1);
        break;

      case MediaButton.previous:
        break;
    }
  }

  @override
  Future<void> onPlay() async => player.play();

  @override
  Future<void> onPause() async => player.pause();

  @override
  Future<void> onSkipToNext() async => player.skipTo(1);

  @override
  Future<void> onSkipToQueueItem(String mediaId) async => player.skipTo(musicProvider.queue.indexWhere((mediaItem) => mediaItem.id == mediaId));

  @override
  Future<void> onFastForward() async => player.fastForward(15000);

  @override
  Future<void> onRewind() async => player.rewind(15000);

  @override
  Future<void> onSeekTo(Duration duration) async => player.seekTo(duration.inMilliseconds);

  @override
  Future<void> onSetRating(Rating rating, Map extras) async {
    // TODO: implement onSetRating
    super.onSetRating(rating, extras);
  }

  @override
  Future<void> onStop() async {
    // Shut down the nameserver port used to receive music providers
    IsolateNameServer.removePortNameMapping('audio_task');

    // Stop and dispose the player
    await player.stop();
    await player.dispose();

    // Update the playback state to indicate that the service is stopped
    await updatePlaybackState(AudioProcessingState.completed);

    // Stop the service
    await super.onStop();
  }

  // A function to load media URLs from the music provider.
  Future<void> load(bool firstLoad) async {
    final List<String> urls = await musicProvider.load(user);
    player.addAllToQueue(urls, firstLoad);
    // TODO the media service queue doesn't always get updated
  }

  // A function to update the media metadata, used by the system.
  void updateCurrentMediaInfo(bool updatePlaybackState) async {
    if (musicProvider.count == 0) return;

    // Get the media duration
    final duration = await player.getDuration();

    MediaItem mediaItem = musicProvider.currentMediaItem;
    List<MediaItem> queue = musicProvider.queue;

    mediaItem = musicProvider.currentMediaItem.copyWith(
      duration: duration == 0 ? null : Duration(milliseconds: duration),
    );

    queue[0] = mediaItem;

    // Set metadata for the playing media
    AudioServiceBackground.setMediaItem(mediaItem);

    // Set the queue, used by Android Auto and some custom ROMs
    // Artwork preloading is done elsewhere, see "Architectural quirks.md".
    AudioServiceBackground.setQueue(queue, preloadArtwork: false);

    // Update the playback state for the new position.
    if (updatePlaybackState) this.updatePlaybackState(AudioServiceBackground.state.processingState);
  }
}