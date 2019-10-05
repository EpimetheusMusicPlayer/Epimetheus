import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/pages/navigation_drawer.dart';
import 'package:epimetheus/widgets/misc/audio_service_display.dart';
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

class MediaControlBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          const IconButton(
            icon: const Icon(Icons.fast_rewind),
            onPressed: AudioService.rewind,
          ),
          StreamBuilder<PlaybackState>(
            initialData: AudioService.playbackState,
            stream: AudioService.playbackStateStream,
            builder: (context, snapshot) {
              print('Buildin\'');
              final paused = snapshot.data.basicState == BasicPlaybackState.paused;
              return IconButton(
                icon: Icon(paused ? Icons.play_arrow : Icons.pause),
                onPressed: paused ? AudioService.play : AudioService.pause,
              );
            },
          ),
          const IconButton(
            icon: const Icon(Icons.fast_forward),
            onPressed: AudioService.fastForward,
          ),
          const IconButton(
            icon: const Icon(Icons.skip_next),
            onPressed: AudioService.skipToNext,
          ),
        ],
      ),
    );
  }
}
