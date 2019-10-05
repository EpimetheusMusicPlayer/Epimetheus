import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/widgets/audio/audio_service_display.dart';
import 'package:flutter/material.dart';

class MediaControlBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    assert(
      context.ancestorWidgetOfExactType(AudioServiceDisplay) != null,
      'MediaControlBar must be a descendant of AudioServiceDisplay!',
    );

    assert(
      AudioService.playbackState != null,
      'The audio service has no published playback state! Is it running?',
    );

    return Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          const IconButton(
            icon: const Icon(Icons.stop),
            onPressed: AudioService.stop,
          ),
          const IconButton(
            icon: const Icon(Icons.fast_rewind),
            onPressed: AudioService.rewind,
          ),
          StreamBuilder<PlaybackState>(
            initialData: AudioService.playbackState,
            stream: AudioService.playbackStateStream,
            builder: (context, snapshot) {
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
