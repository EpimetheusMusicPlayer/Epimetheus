import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/models/color/color_model.dart';
import 'package:epimetheus/pages/now_playing/song_display.dart';
import 'package:epimetheus/widgets/audio/media_control_bar.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controller.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/material.dart';

class NowPlayingContent extends StatefulWidget {
  @override
  _NowPlayingContentState createState() => _NowPlayingContentState();
}

class _NowPlayingContentState extends State<NowPlayingContent> {
  bool firstPage = true;
  MediaItem _selectedMediaItem;

  @override
  void initState() {
    super.initState();
    _selectedMediaItem = AudioService.currentMediaItem;
  }

  @override
  Widget build(BuildContext context) {
    final model = ColorModel.of(context, rebuildOnChange: true);

    void onPageChanged(int newPage) {
      setState(() {
        firstPage = newPage == 0;
        _selectedMediaItem = AudioService.queue[newPage];
      });
    }

    return SizedBox.expand(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        color: model.backgroundColor,
        child: SafeArea(
          child: Stack(
            children: <Widget>[
              SongDisplay(onPageChanged),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SizedBox(
                  child: SeamlessMediaControls(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SeamlessMediaControls extends StatefulWidget {
  @override
  _SeamlessMediaControlsState createState() => _SeamlessMediaControlsState();
}

class _SeamlessMediaControlsState extends State<SeamlessMediaControls> with SingleTickerProviderStateMixin {
  static const double iconSize = 36;
  static const animationDuration = const Duration(milliseconds: 150);

  StreamSubscription<PlaybackState> _playbackStateListener;

  FlareControls _rewindController = FlareControls();
  AnimationController _playPauseController;
  FlareControls _fastForwardController = FlareControls();
  FlareControls _skipController = FlareControls();

  @override
  void initState() {
    super.initState();
    _playPauseController = AnimationController(
      vsync: this,
      duration: animationDuration,
    );

    _playbackStateListener = AudioService.playbackStateStream.listen((playbackState) {
      if (playbackState.basicState == BasicPlaybackState.paused)
        _playPauseController.forward();
      else
        _playPauseController.reverse();
    });
  }

  @override
  void dispose() {
    _playbackStateListener.cancel();
    _playPauseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = ColorModel.of(context, rebuildOnChange: true);

    final colorFilter = ColorFilter.mode(
      model.readableForegroundColor,
      BlendMode.srcIn,
    );

    return SizedBox(
      height: 72,
      child: Material(
        color: Colors.transparent,
        child: ColorFiltered(
          colorFilter: colorFilter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              const IconButton(
                icon: const Icon(Icons.stop),
                iconSize: iconSize,
                onPressed: AudioService.stop,
              ),
              IconButton(
                icon: Transform.scale(
                  scale: -1,
                  child: FlareActor(
                    'assets/fast_forward.flr',
                    controller: _rewindController,
                    color: model.readableForegroundColor,
                  ),
                ),
                iconSize: iconSize,
                onPressed: () {
                  _rewindController.play('fast_forward');
                  AudioService.fastForward();
                },
              ),
              IconButton(
                icon: AnimatedIcon(
                  progress: _playPauseController,
                  icon: AnimatedIcons.pause_play,
                ),
                iconSize: iconSize,
                onPressed: () {
                  if (AudioService.playbackState.basicState == BasicPlaybackState.paused)
                    AudioService.play();
                  else
                    AudioService.pause();
                },
              ),
              IconButton(
                icon: FlareActor(
                  'assets/fast_forward.flr',
                  controller: _fastForwardController,
                  color: model.readableForegroundColor,
                ),
                iconSize: iconSize,
                onPressed: () {
                  _fastForwardController.play('fast_forward');
                  AudioService.fastForward();
                },
              ),
              IconButton(
                icon: FlareActor(
                  'assets/skip.flr',
                  controller: _skipController,
                  color: model.readableForegroundColor,
                ),
                iconSize: iconSize,
                onPressed: () {
                  _skipController.play('skip');
                  AudioService.skipToNext();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
