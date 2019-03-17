import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/audio/music_provider.dart';
import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:epimetheus/libepimetheus/networking.dart';
import 'package:qudio/qudio.dart';

/// After calling this method, send the needed data to the receiveport. Example:
/// IsolateNameServer.lookupPortByName('audio_task').send(
//    <dynamic>[
//      model.user,
//      StationMusicProvider(await model.getStations(), 1),
//      csrfToken,
//    ],
//  );
Future<bool> startAudioTask() {
  return AudioService.start(
    backgroundTask: audioTask,
    androidNotificationChannelName: 'Media',
    androidNotificationChannelDescription: 'Media information and controls.',
  );
}

// TODO error handling

void audioTask() async {
  Completer<void> serviceCompleter = Completer<void>();

  User user;
  MusicProvider musicProvider;

  final ReceivePort receivePort = ReceivePort();
  IsolateNameServer.registerPortWithName(receivePort.sendPort, 'audio_task');

  final List<MediaControl> mediaControls = <MediaControl>[
    MediaControl(label: 'Stop', androidIcon: 'drawable/ic_stop', action: MediaAction.stop),
    MediaControl(label: 'Rewind', androidIcon: 'drawable/ic_rewind', action: MediaAction.rewind),
    null,
    MediaControl(label: 'Fast-forward', androidIcon: 'drawable/ic_fast_forward', action: MediaAction.fastForward),
    MediaControl(label: 'Skip', androidIcon: 'drawable/ic_skip', action: MediaAction.skipToNext),
  ];

  void togglePlayPauseControl(bool paused) {
    mediaControls[2] = paused
        ? MediaControl(
            label: 'Play',
            androidIcon: 'drawable/ic_play',
            action: MediaAction.play,
          )
        : MediaControl(
            label: 'Pause',
            androidIcon: 'drawable/ic_pause',
            action: MediaAction.pause,
          );
  }

  Future<void> updateBasicPlaybackState(BasicPlaybackState basicPlaybackState) {
    return AudioServiceBackground.setState(
      controls: mediaControls,
      androidCompactActions: <int>[2, 3, 4],
      basicState: basicPlaybackState,
      position: 0,
      // TODO there's lag here. (await audioPlayer.onAudioPositionChanged.first).inMilliseconds,
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
    if (musicProvider.count == 0) {
      togglePlayPauseControl(true);
      updateBasicPlaybackState(BasicPlaybackState.buffering);
      onUrlsAdded(await musicProvider.load(user));
    }
    if (musicProvider.count <= 2) {
      musicProvider.load(user).then((List<String> result) {
        if (result != null) {
          AudioServiceBackground.setQueue(musicProvider.queue);
          onUrlsAdded(result);
        }
      });
    }
//    audioPlayer.play(musicProvider.audioUrl).then((_) async {
//      // TODO code not working. Should update duration in mediaSession.
////      MediaItem mediaItem = musicProvider.currentMediaItem;
////      mediaItem.duration = audioPlayer.duration.inMilliseconds;
////      AudioServiceBackground.setMediaItem(mediaItem);
//
//      togglePlayPauseControl(false);
//      updateBasicPlaybackState(BasicPlaybackState.playing);
//    });
    if (skipToNext) {
      Qudio.removeFromQueue(0);
      musicProvider.skip();
    }
    AudioServiceBackground.setMediaItem(musicProvider.currentMediaItem);
    AudioServiceBackground.setQueue(musicProvider.queue);
  }

  receivePort.listen((data) async {
    if (data is List<dynamic>) {
      user = data[0];
      csrfToken = data[2];

      if (musicProvider != data[1]) {
        AudioServiceBackground.setMediaItem(
          MediaItem(
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
        musicProvider = data[1];

        onUrlsAdded(await musicProvider.load(user));
        newSong(false);
      }
    }
  });

  AudioServiceBackground.run(
    onStart: () {
      Qudio.connect();
      return serviceCompleter.future;
    },
    onPause: () {
      Qudio.pause();
    },
    onPlay: () {
      Qudio.play();
    },
    onFastForward: () async {
      Qudio.fastForward(15000);
    },
    onRewind: () async {
      Qudio.rewind(15000);
    },
    onSkipToNext: () {
      newSong(true);
    },
    onStop: () async {
      await updateBasicPlaybackState(BasicPlaybackState.stopped);
      await Qudio.stop();
      Qudio.disconnect();
      serviceCompleter.complete();
    },
    onSetRating: (Rating rating, Map<dynamic, dynamic> extras) {
      print('RATING: $rating, $extras');
    },
  );

  Qudio.playbackStatusStream.listen((QudioPlaybackStatus status) {
    switch (status.playbackState) {
      case QudioPlaybackState.STATE_BUFFERING:
        togglePlayPauseControl(false);
        updateBasicPlaybackState(BasicPlaybackState.buffering);
        break;

      case QudioPlaybackState.STATE_READY:
        togglePlayPauseControl(!status.playing);
        updateBasicPlaybackState(status.playing ? BasicPlaybackState.playing : BasicPlaybackState.paused);
        break;

      case QudioPlaybackState.STATE_IDLE:
        break;

      case QudioPlaybackState.STATE_ENDED:
        break;
    }
  });

  Qudio.positionDiscontinuityStream.listen((PositionDiscontinuityReason reason) {
    print('REASON: $reason');
    if (reason == PositionDiscontinuityReason.DISCONTINUITY_REASON_PERIOD_TRANSITION) {
      musicProvider.skip();
      newSong(false);
    }
  });
}
