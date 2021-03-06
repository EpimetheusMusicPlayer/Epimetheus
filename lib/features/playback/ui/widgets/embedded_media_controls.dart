import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:epimetheus_nullable/mobx/playback/playback_store.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

class EmbeddedMediaControls extends StatefulWidget {
  static const double iconSize = 36;
  static const double height = iconSize * 2;
  static const animationDuration = Duration(milliseconds: 150);

  /// True to adjust icon colors based on the playing media's dominant color.
  final bool dynamicColors;

  const EmbeddedMediaControls({
    Key? key,
    this.dynamicColors = false,
  }) : super(key: key);

  @override
  _EmbeddedMediaControlsState createState() => _EmbeddedMediaControlsState();
}

class _EmbeddedMediaControlsState extends State<EmbeddedMediaControls>
    with SingleTickerProviderStateMixin {
  final playbackStore = GetIt.instance<PlaybackStore>();

  late final StreamSubscription<PlaybackState> _playbackStateListener;

  final FlareControls _rewindController = FlareControls();
  late final AnimationController _playPauseController = AnimationController(
    vsync: this,
    duration: EmbeddedMediaControls.animationDuration,
  );
  final FlareControls _fastForwardController = FlareControls();
  final FlareControls _skipController = FlareControls();

  @override
  void initState() {
    super.initState();
    _playbackStateListener =
        AudioService.playbackStateStream.listen((PlaybackState? playbackState) {
      if (playbackState == null) return;
      if (playbackState.playing) {
        _playPauseController.reverse();
      } else {
        _playPauseController.forward();
      }
    });
  }

  @override
  void dispose() {
    _playbackStateListener.cancel();
    _playPauseController.dispose();
    super.dispose();
  }

  Widget _buildControlRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        const IconButton(
          icon: Icon(Icons.stop),
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
              color: Colors.white,
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
            if (AudioService.playbackState.playing) {
              AudioService.pause();
            } else {
              AudioService.play();
            }
          },
        ),
        IconButton(
          icon: FlareActor(
            'assets/fast_forward.flr',
            controller: _fastForwardController,
            color: Colors.white,
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
            color: Colors.white,
          ),
          iconSize: EmbeddedMediaControls.iconSize,
          tooltip: 'Skip',
          onPressed: () {
            _skipController.play('skip');
            AudioService.skipToNext();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: EmbeddedMediaControls.height,
      child: Material(
        color: Colors.transparent,
        child: widget.dynamicColors
            ? Observer(
                builder: (context) => ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    playbackStore.isDominantColorDark
                        ? Colors.white
                        : Colors.black,
                    BlendMode.srcIn,
                  ),
                  child: _buildControlRow(),
                ),
              )
            : _buildControlRow(),
      ),
    );
  }
}
