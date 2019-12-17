import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:epimetheus/pages/navigation_drawer.dart';
import 'package:epimetheus/pages/now_playing/now_playing_content.dart';
import 'package:epimetheus/pages/now_playing/song_display.dart';
import 'package:epimetheus/widgets/audio/audio_service_display.dart';
import 'package:epimetheus/widgets/audio/media_control_bar.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

class NowPlayingPage extends StatefulWidget {
  @override
  _NowPlayingPageState createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage> {
  final Map<String, PaletteGenerator> _palettes = {};
  StreamSubscription<List<MediaItem>> _queueListener;

  @override
  initState() {
    super.initState();
    _queueListener = AudioService.queueStream.listen((queue) async {
      for (MediaItem mediaItem in queue) {
        if (!_palettes.containsKey(mediaItem.artUri)) {
          // Initialise the key so it doesn't launch multiple palette generator generations while the first is still generating
          _palettes[mediaItem.artUri] = null;
          _palettes[mediaItem.artUri] = await PaletteGenerator.fromImageProvider(CachedNetworkImageProvider(mediaItem.artUri));
        }
      }
    });
  }

  @override
  dispose() {
    _queueListener.cancel();
    super.dispose();
  }

  Future<PaletteGenerator> _getPaletteGenerator(String artUri) async {
    if (_palettes.containsKey(artUri)) {
      final paletteGenerator = _palettes[artUri];
      if (paletteGenerator != null) return paletteGenerator;
    }

    return await PaletteGenerator.fromImageProvider(CachedNetworkImageProvider(artUri));
  }

  Widget _buildNothingPlayingIndicator() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const <Widget>[
          const Icon(
            Icons.volume_off,
            size: 128,
            color: Colors.black26,
          ),
          const SizedBox(height: 32),
          const Text(
            'Nothing playing',
            textScaleFactor: 2,
            style: const TextStyle(
              color: Colors.black26,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    Color _getBackgroundColor(PaletteGenerator paletteGenerator) {
      if (paletteGenerator == null) return null;
      if (paletteGenerator.dominantColor != null) return paletteGenerator.dominantColor.color;
      if (paletteGenerator.darkMutedColor != null) return paletteGenerator.darkMutedColor.color;
      if (paletteGenerator.darkVibrantColor != null) return paletteGenerator.darkVibrantColor.color;
      return primaryColor;
    }

    return AudioServiceDisplay(
      child: FutureBuilder<bool>(
        future: AudioService.running,
        builder: (context, runningSnapshot) {
          // Don't show anything while checking id the audio service is running
          if (!runningSnapshot.hasData) return Container();

          // Rebuilds when the current media item changes
          return StreamBuilder<List<MediaItem>>(
            stream: AudioService.queueStream,
            builder: (context, queue) {
              // Generates the PaletteGenerator for the current media item
              return FutureBuilder<PaletteGenerator>(
                future: queue.data?.elementAt(0)?.artUri == null // If there's no current media item, don't generate a pallete generator
                    ? null
                    : _getPaletteGenerator(queue.data[0].artUri),
                builder: (context, paletteGeneratorSnapshot) {
                  final running = runningSnapshot.data && AudioService.playbackState != null && (queue.data?.elementAt(0)?.id ?? 'loading') != 'loading';
                  final backgroundColor = _getBackgroundColor(paletteGeneratorSnapshot.data);

                  return Scaffold(
                    extendBodyBehindAppBar: true,
                    drawer: const NavigationDrawer(
                      currentRouteName: '/now-playing',
                    ),
                    appBar: AppBar(
                      title: Text(
                        'Now Playing',
                      ),
                      backgroundColor: running ? Colors.transparent : null,
                    ),
                    body: running
                        ? NowPlayingContent(
                            backgroundColor: backgroundColor,
                            queue: queue.data,
                          )
                        : _buildNothingPlayingIndicator(),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
