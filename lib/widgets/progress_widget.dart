import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

class ProgressWidget extends StatefulWidget {
  @override
  _ProgressWidgetState createState() => _ProgressWidgetState();
}

class _ProgressWidgetState extends State<ProgressWidget> with WidgetsBindingObserver {
  static const _delimiter = ':';
  String _positionMinutes = '00';
  String _positionSeconds = '00';
  String _durationMinutes = '00';
  String _durationSeconds = '00';
  Timer _timer;

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      Duration(milliseconds: 200),
      (_) {
        final position = AudioService.playbackState?.basicState == BasicPlaybackState.playing
            ? (DateTime.now().millisecondsSinceEpoch - AudioService.playbackState.updateTime + AudioService.playbackState.position) / 1000
            : AudioService.playbackState?.position ?? 0 / 1000;
        final duration = (AudioService.currentMediaItem.duration ?? 0) / 1000;
        setState(() {
          _positionMinutes = (position / 60).floor().toString().padLeft(2, '0');
          _positionSeconds = (position % 60).floor().toString().padLeft(2, '0');
          _durationMinutes = ((duration ?? 0) / 60).floor().toString().padLeft(2, '0');
          _durationSeconds = ((duration ?? 0) % 60).floor().toString().padLeft(2, '0');
        });
      },
    );
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      startTimer();
    } else if (state == AppLifecycleState.paused) {
      stopTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _positionMinutes + _delimiter + _positionSeconds + ' / ' + _durationMinutes + _delimiter + _durationSeconds,
      style: TextStyle(color: Theme.of(context).primaryTextTheme.title.color),
    );
  }
}
