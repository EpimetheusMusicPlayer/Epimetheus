import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/models/color/color_model.dart';
import 'package:epimetheus/pages/navigation_drawer.dart';
import 'package:epimetheus/pages/now_playing/now_playing_content.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:scoped_model/scoped_model.dart';

class NowPlayingPage extends StatefulWidget {
  @override
  _NowPlayingPageState createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage> {
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

    return FutureBuilder<bool>(
      future: AudioService.running,
      builder: (context, runningSnapshot) {
        // Don't show anything while checking id the audio service is running
        if (!runningSnapshot.hasData) return Container();

        // Rebuilds when the current media item changes
        return StreamBuilder<List<MediaItem>>(
          stream: AudioService.queueStream,
          builder: (context, queue) {
            final running = runningSnapshot.data &&
                AudioService.playbackState != null &&
                (queue.data?.length ?? 0) > 0 &&
                (queue.data?.elementAt(0)?.id ?? 'loading') != 'loading';

            final model = ColorModel.of(context, rebuildOnChange: true);

            return Scaffold(
              extendBodyBehindAppBar: true,
              drawer: const NavigationDrawer(
                currentRouteName: '/now-playing',
              ),
              appBar: AppBar(
                iconTheme: IconThemeData(
                  color: model.readableForegroundColor ?? Colors.white
                ),
                title: Text(
                  'Now Playing',
                  style: TextStyle(
                    color: model.readableForegroundColor,
                  ),
                ),
                backgroundColor: running ? Colors.transparent : null,
                elevation: running ? 0 : null,
              ),
              body: running
                  ? NowPlayingContent(
                    )
                  : _buildNothingPlayingIndicator(),
            );
          },
        );
      },
    );
  }
}
