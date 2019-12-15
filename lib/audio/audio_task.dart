import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/audio/music_provider.dart';
import 'package:epimetheus/audio/players/android_player.dart';
import 'package:epimetheus/audio/players/iOS_player.dart';
import 'package:epimetheus/audio/players/player.dart';
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
  assert(user != null, 'User is null!');
  assert(musicProvider != null, 'MusicProvider is null!');
  await AudioService.connect();
  await AudioService.start(
    backgroundTaskEntrypoint: audioTaskEntryPoint,
    enableQueue: true,
    androidNotificationIcon: 'mipmap/ic_launcher_foreground',
    androidNotificationChannelName: 'Media',
    androidNotificationChannelDescription: 'Media information and controls',
    androidNotificationOngoing: true,
  );
  AudioService.disconnect();
  IsolateNameServer.lookupPortByName('audio_task').send(
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

    void onPlaybackStateChange(BasicPlaybackState newPlaybackState) {
      switch (newPlaybackState) {
        case BasicPlaybackState.paused:
          togglePlayPauseControl(true);
          updateBasicPlaybackState(newPlaybackState);
          break;

        case BasicPlaybackState.playing:
          togglePlayPauseControl(false);
          updateBasicPlaybackState(newPlaybackState);
          break;

        case BasicPlaybackState.buffering:
          togglePlayPauseControl(false);
          updateBasicPlaybackState(newPlaybackState);
          break;

        case BasicPlaybackState.none:
          break;
        case BasicPlaybackState.stopped:
          break;
        case BasicPlaybackState.fastForwarding:
          break;
        case BasicPlaybackState.rewinding:
          break;
        case BasicPlaybackState.error:
          break;
        case BasicPlaybackState.connecting:
          break;
        case BasicPlaybackState.skippingToPrevious:
          break;
        case BasicPlaybackState.skippingToNext:
          break;
        case BasicPlaybackState.skippingToQueueItem:
          break;
      }
    }

    void onSongAdvancement(int newQueueSize) {
      musicProvider.skipTo(musicProvider.count - newQueueSize);
      updateCurrentPlaybackInfo();
    }

    void onError() {
      onStop();
    }

    if (Platform.isAndroid)
      player = AndroidPlayer(
        onPlaybackStateChange: onPlaybackStateChange,
        onSongAdvancement: onSongAdvancement,
        onError: onError,
        onSeek: () {},
      );
    else if (Platform.isIOS)
      player = iOSPlayer(
        onPlaybackStateChange: onPlaybackStateChange,
        onSongAdvancement: onSongAdvancement,
        onError: onError,
        onSeek: () {},
      );
    else
      throw Exception('Unsupported platform!');

    receivePort.listen((payload) async {
      if (payload is _AudioTaskPayload) {
        user = payload.user;
        csrfToken = payload.csrfToken;

        if (musicProvider != payload.musicProvider) {
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

          player.stop();

          togglePlayPauseControl(false);
          updateBasicPlaybackState(BasicPlaybackState.buffering);

          musicProvider = payload.musicProvider;

          await load();
          updateCurrentPlaybackInfo();
        }
      }
    });
  }

  void togglePlayPauseControl(bool paused) {
    mediaControls[2] = paused
        ? const MediaControl(
            label: 'Play',
            androidIcon: 'drawable/ic_play',
            action: MediaAction.play,
          )
        : const MediaControl(
            label: 'Pause',
            androidIcon: 'drawable/ic_pause',
            action: MediaAction.pause,
          );
  }

  Future<void> updateBasicPlaybackState(BasicPlaybackState basicPlaybackState) async {
    return AudioServiceBackground.setState(
      controls: mediaControls,
      androidCompactActions: const <int>[2, 3, 4],
      basicState: basicPlaybackState,
      position: (await player.getPosition()) ?? 0,
      updateTime: DateTime.now().millisecondsSinceEpoch,
      speed: 1,
    );
  }

  @override
  Future<void> onStart() {
    player.init();
    return serviceCompleter.future;
  }

  @override
  void onClick(MediaButton button) {
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
  void onPlay() => player.play();

  @override
  void onPause() => player.pause();

  @override
  void onSkipToNext() => player.skipTo(1);

  @override
  void onSkipToQueueItem(String mediaId) => player.skipTo(musicProvider.queue.indexWhere((mediaItem) => mediaItem.id == mediaId));

  @override
  void onFastForward() => player.fastForward(15000);

  @override
  void onRewind() => player.rewind(15000);

  @override
  void onSeekTo(int ms) => player.seekTo(ms);

  @override
  void onSetRating(Rating rating, Map extras) {
    // TODO: implement onSetRating
    super.onSetRating(rating, extras);
  }

  @override
  void onStop() async {
    IsolateNameServer.removePortNameMapping('audio_task');
    player.stop();
    player.dispose();
    await updateBasicPlaybackState(BasicPlaybackState.stopped);
    serviceCompleter.complete();
  }

  Future<void> load() async {
    final List<String> urls = await musicProvider.load(user);
    player.addAllToQueue(urls, musicProvider.queue.length <= urls.length);
  }

  void updateCurrentPlaybackInfo() {
    AudioServiceBackground.setMediaItem(musicProvider.currentMediaItem);
    AudioServiceBackground.setQueue(musicProvider.queue);
    updateBasicPlaybackState(AudioServiceBackground.state.basicState);
  }
}
