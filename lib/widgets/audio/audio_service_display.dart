import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

/// Legacy code; unused. No longer necessary thanks to the addition of [AudioServiceWidget] in audio_service.
class AudioServiceDisplay extends StatefulWidget {
  final Widget child;

  @override
  _AudioServiceDisplayState createState() => _AudioServiceDisplayState();

  AudioServiceDisplay({
    Key key,
    @required this.child,
  }) : super(key: key);
}

class _AudioServiceDisplayState extends State<AudioServiceDisplay> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    print('Init');
    AudioService.connect();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        print('Paused');
        AudioService.disconnect();
        break;
      case AppLifecycleState.resumed:
        print('Resumed');
        AudioService.connect();
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    print('Dispose');
    AudioService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
