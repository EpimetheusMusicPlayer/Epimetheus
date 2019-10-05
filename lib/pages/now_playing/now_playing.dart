import 'package:epimetheus/pages/navigation_drawer.dart';
import 'package:epimetheus/widgets/audio/audio_service_display.dart';
import 'package:epimetheus/widgets/audio/media_control_bar.dart';
import 'package:flutter/material.dart';

class NowPlayingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavigationDrawer(
        currentRouteName: '/now-playing',
      ),
      appBar: AppBar(
        title: const Text('Now Playing'),
      ),
      body: AudioServiceDisplay(
        child: MediaControlBar(),
      ),
    );
  }
}
