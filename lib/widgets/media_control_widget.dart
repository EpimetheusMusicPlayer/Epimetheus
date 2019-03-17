import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/models/model.dart';
import 'package:flutter/material.dart';

class MediaControlWidget extends StatefulWidget {
  final bool _showHUD;

  const MediaControlWidget([this._showHUD = true]);

  @override
  _MediaControlWidgetState createState() => _MediaControlWidgetState();
}

class _MediaControlWidgetState extends State<MediaControlWidget> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  AnimationController _controller;
  StreamSubscription<PlaybackState> _playbackStateSubscription;

  void startListening() {
    _playbackStateSubscription?.cancel();
    _playbackStateSubscription = AudioService.playbackStateStream.listen((state) {
      if (state.basicState == BasicPlaybackState.paused) {
        _controller.reverse(from: 1);
      } else if (state.basicState == BasicPlaybackState.playing) {
        _controller.forward(from: 0);
      }
    });
  }

  void stopListening() {
    _playbackStateSubscription?.cancel();
    _playbackStateSubscription = null;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: AudioService.playbackState?.basicState == BasicPlaybackState.playing ? 1 : 0,
    );
    startListening();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      startListening();
    } else if (state == AppLifecycleState.paused) {
      stopListening();
    }
  }

  @override
  void dispose() {
    stopListening();
    _controller.dispose();
    super.dispose();
  }

  void playPause() {
    if (AudioService.playbackState.basicState == BasicPlaybackState.paused) {
      AudioService.play();
      _controller.forward(from: 0);
    } else if (AudioService.playbackState.basicState == BasicPlaybackState.playing) {
      AudioService.pause();
      _controller.reverse(from: 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(blurRadius: 4)],
        borderRadius: const BorderRadius.only(
          topLeft: const Radius.circular(2),
          topRight: const Radius.circular(2),
        ),
      ),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        color: EpimetheusModel.of(context, rebuildOnChange: true).inheritedAlbumArtColor,
        child: Material(
          type: MaterialType.transparency,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const IconButton(
                color: Colors.white,
                iconSize: 36,
                icon: Icon(
                  Icons.stop,
                ),
                onPressed: AudioService.stop,
              ),
              const IconButton(
                color: Colors.white,
                iconSize: 36,
                icon: Icon(
                  Icons.fast_rewind,
                ),
                onPressed: AudioService.rewind,
              ),
              IconButton(
                color: Colors.white,
                iconSize: 36,
                icon: AnimatedIcon(
                  icon: AnimatedIcons.play_pause,
                  progress: _controller,
                ),
                onPressed: playPause,
              ),
              const IconButton(
                color: Colors.white,
                iconSize: 36,
                icon: Icon(
                  Icons.fast_forward,
                ),
                onPressed: AudioService.fastForward,
              ),
              const IconButton(
                color: Colors.white,
                iconSize: 36,
                icon: Icon(
                  Icons.skip_next,
                ),
                onPressed: AudioService.skipToNext,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
