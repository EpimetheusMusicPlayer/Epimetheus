import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/pages/now_playing/song_display.dart';
import 'package:epimetheus/widgets/audio/media_control_bar.dart';
import 'package:flutter/material.dart';

class NowPlayingContent extends StatelessWidget {
  final Color backgroundColor;
  final List<MediaItem> queue;

  NowPlayingContent({
    @required this.backgroundColor,
    @required this.queue,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        color: backgroundColor,
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: SongDisplay(
                  queue: queue,
                  backgroundColor: backgroundColor,
                ),
              ),
              MediaControlBar(),
            ],
          ),
        ),
      ),
    );
  }
}
