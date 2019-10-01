import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/audio/music_provider.dart';
import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:epimetheus/libepimetheus/networking.dart';
import 'package:meta/meta.dart';
import 'package:qudio/qudio.dart';

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
    androidNotificationChannelName: 'Media',
    androidNotificationChannelDescription: 'Media information and controls',
    androidNotificationOngoing: true,
  );
  IsolateNameServer.lookupPortByName('audio_task').send(
    _AudioTaskPayload(
      user: user,
      musicProvider: musicProvider,
      csrfToken: csrfToken,
    ),
  );
}

void audioTaskEntryPoint() {
  AudioServiceBackground.run(() => EpimetheusAudioTask());
}

class EpimetheusAudioTask extends BackgroundAudioTask {
  Completer<void> serviceCompleter = Completer<void>();

  User user;
  MusicProvider musicProvider;

  final ReceivePort receivePort = ReceivePort();

  StreamSubscription<QudioPlaybackStatus> playbackStatusStream;
  StreamSubscription<PositionDiscontinuityReason> positionDiscontinuityStream;
  StreamSubscription<bool> sourceErrorStream;

  final List<MediaControl> mediaControls = <MediaControl>[
    const MediaControl(label: 'Stop', androidIcon: 'drawable/ic_stop', action: MediaAction.stop),
    const MediaControl(label: 'Rewind', androidIcon: 'drawable/ic_rewind', action: MediaAction.rewind),
    null,
    const MediaControl(label: 'Fast-forward', androidIcon: 'drawable/ic_fast_forward', action: MediaAction.fastForward),
    const MediaControl(label: 'Skip', androidIcon: 'drawable/ic_skip', action: MediaAction.skipToNext),
  ];

  EpimetheusAudioTask() {
    print('Contructing');
    IsolateNameServer.registerPortWithName(receivePort.sendPort, 'audio_task');

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
          togglePlayPauseControl(false);
          updateBasicPlaybackState(BasicPlaybackState.buffering);

          Qudio.stop();
          musicProvider = payload.musicProvider;

          onUrlsAdded(await musicProvider.load(user));
          newSong(false);
        }
      }
    });

    playbackStatusStream = Qudio.playbackStatusStream.listen((QudioPlaybackStatus status) async {
      switch (status.playbackState) {
        case QudioPlaybackState.STATE_BUFFERING:
          togglePlayPauseControl(false);
          updateBasicPlaybackState(BasicPlaybackState.buffering);
          break;

        case QudioPlaybackState.STATE_READY:
          final updateDuration = AudioServiceBackground.state.basicState == BasicPlaybackState.buffering && status.playing == true;
          togglePlayPauseControl(!status.playing);
          updateBasicPlaybackState(status.playing ? BasicPlaybackState.playing : BasicPlaybackState.paused);

          if (updateDuration) {
            MediaItem mediaItem = musicProvider.currentMediaItem;
            mediaItem = MediaItem(
              id: mediaItem.id,
              title: mediaItem.title,
              artist: mediaItem.artist,
              album: mediaItem.album,
              displayTitle: mediaItem.displayTitle,
              displaySubtitle: mediaItem.displaySubtitle,
              displayDescription: mediaItem.displayDescription,
              artUri: mediaItem.artUri,
              genre: mediaItem.genre,
              playable: mediaItem.playable,
              rating: mediaItem.rating,
              duration: await Qudio.currentDuration,
            );
            AudioServiceBackground.setMediaItem(mediaItem);
          }
          break;

        case QudioPlaybackState.STATE_IDLE:
          break;

        case QudioPlaybackState.STATE_ENDED:
          break;
      }
    });

    positionDiscontinuityStream = Qudio.positionDiscontinuityStream.listen((PositionDiscontinuityReason reason) async {
      if (reason == PositionDiscontinuityReason.DISCONTINUITY_REASON_PERIOD_TRANSITION) {
        musicProvider.skipTo(musicProvider.count - await Qudio.queueSize);
        newSong(false);
      }
    });

    sourceErrorStream = Qudio.sourceErrorStream.listen((error) {
      if (error) onStop();
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
      androidCompactActions: <int>[2, 3, 4],
      basicState: basicPlaybackState,
      position: await Qudio.currentPosition,
      updateTime: DateTime.now().millisecondsSinceEpoch,
      speed: 1,
    );
  }

  void onUrlsAdded(List<String> urls) {
    Qudio.addAllToQueue(urls);
    if (musicProvider.queue.length - urls.length <= 0) {
      Qudio.begin();
    }
  }

  void newSong(bool skipToNext) async {
    Qudio.play();
    if (musicProvider.count == 0) {
      togglePlayPauseControl(true);
      updateBasicPlaybackState(BasicPlaybackState.buffering);
      final newUrls = await musicProvider.load(user);
      if (newUrls == null) {
        onStop();
        return;
      }
      onUrlsAdded(newUrls);
    }
    if (musicProvider.count <= (skipToNext ? 3 : 2)) {
      musicProvider.load(user).then((List<String> result) {
        if (result != null) {
          AudioServiceBackground.setQueue(musicProvider.queue);
          onUrlsAdded(result);
        }
      });
    }
    if (skipToNext) {
      Qudio.removeFromQueue(0);
      musicProvider.skip();
    }

    AudioServiceBackground.setMediaItem(musicProvider.currentMediaItem);
    AudioServiceBackground.setQueue(musicProvider.queue);
    updateBasicPlaybackState(AudioServiceBackground.state.basicState);
  }

  @override
  Future<void> onStart() {
    Qudio.connect();
    return serviceCompleter.future;
  }

  @override
  void onPause() => Qudio.pause();

  @override
  void onPlay() => Qudio.play();

  @override
  void onFastForward() => Qudio.fastForward(15000);

  @override
  void onRewind() => Qudio.rewind(15000);

  @override
  void onSkipToNext() => newSong(true);

  @override
  void onSkipToQueueItem(String id) => Qudio.skipTo(musicProvider.queue.indexWhere((mediaItem) => mediaItem.id == id));

  @override
  void onSetRating(Rating rating, Map<dynamic, dynamic> extras) => Qudio.fastForward(15000);

  @override
  void onStop() async {
    IsolateNameServer.removePortNameMapping('audio_task');
    await Future.wait([
      playbackStatusStream.cancel(),
      positionDiscontinuityStream.cancel(),
      sourceErrorStream.cancel(),
    ]);
    await updateBasicPlaybackState(BasicPlaybackState.stopped);
    await Qudio.stop();
    serviceCompleter.complete();
  }
}
