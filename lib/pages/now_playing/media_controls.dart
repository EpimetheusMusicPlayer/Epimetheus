import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/models/color/color_model.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/material.dart';

class EmbeddedMediaControls extends StatefulWidget {
  static const double iconSize = 36;
  static const double height = iconSize * 2;
  static const animationDuration = const Duration(milliseconds: 150);

  @override
  _EmbededMediaControlsState createState() => _EmbededMediaControlsState();
}

class _EmbededMediaControlsState extends State<EmbeddedMediaControls> with SingleTickerProviderStateMixin {
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
      duration: EmbeddedMediaControls.animationDuration,
    );

    _playbackStateListener = AudioService.playbackStateStream.listen((playbackState) {
      if (playbackState.playing)
        _playPauseController.reverse();
      else
        _playPauseController.forward();
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
      height: EmbeddedMediaControls.height,
      child: Material(
        color: Colors.transparent,
        child: ColorFiltered(
          colorFilter: colorFilter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              const IconButton(
                icon: const Icon(Icons.stop),
                iconSize: EmbeddedMediaControls.iconSize,
                color: Colors.white,
                tooltip: 'Stop',
                onPressed: AudioService.stop,
              ),
              IconButton(
                icon: Transform.scale(
                  scale: -1,
                  child: FlareActor(
                    'assets/fast_forward.flr',
                    controller: _rewindController,
                  ),
                ),
                iconSize: EmbeddedMediaControls.iconSize,
                tooltip: '-15s',
                onPressed: () {
                  _rewindController.play('fast_forward');
                  AudioService.rewind();
                },
              ),
              IconButton(
                icon: AnimatedIcon(
                  progress: _playPauseController,
                  icon: AnimatedIcons.pause_play,
                ),
                iconSize: EmbeddedMediaControls.iconSize,
                color: Colors.white,
                tooltip: 'Play/pause',
                onPressed: () {
                  if (AudioService.playbackState.playing)
                    AudioService.pause();
                  else
                    AudioService.play();
                },
              ),
              IconButton(
                icon: FlareActor(
                  'assets/fast_forward.flr',
                  controller: _fastForwardController,
                ),
                iconSize: EmbeddedMediaControls.iconSize,
                tooltip: '+15s',
                onPressed: () {
                  _fastForwardController.play('fast_forward');
                  AudioService.fastForward();
                },
              ),
              IconButton(
                icon: FlareActor(
                  'assets/skip.flr',
                  controller: _skipController,
                ),
                iconSize: EmbeddedMediaControls.iconSize,
                tooltip: 'Skip',
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
