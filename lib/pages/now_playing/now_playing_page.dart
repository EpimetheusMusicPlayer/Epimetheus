import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/models/color/color_model.dart';
import 'package:epimetheus/pages/now_playing/now_playing_content.dart';
import 'package:epimetheus/widgets/adaptive/adaptive_drawer_scaffold.dart';
import 'package:flutter/material.dart';

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
    final running = AudioService.running && AudioService.playbackState != null;

    final model = ColorModel.of(context, rebuildOnChange: true);

    return AdaptiveScaffold(
      builder: (drawer, displayMobileLayout) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          drawer: drawer,
          appBar: AppBar(
            automaticallyImplyLeading: displayMobileLayout,
            iconTheme: IconThemeData(color: model.readableForegroundColor ?? Colors.white),
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
                  displayMobileLayout: displayMobileLayout,
                )
              : _buildNothingPlayingIndicator(),
        );
      },
    );
  }
}
