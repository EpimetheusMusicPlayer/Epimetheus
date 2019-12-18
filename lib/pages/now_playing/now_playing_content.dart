import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/models/color/color_model.dart';
import 'package:epimetheus/pages/now_playing/song_display.dart';
import 'package:epimetheus/widgets/audio/media_control_bar.dart';
import 'package:flutter/material.dart';

class NowPlayingContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = ColorModel.of(context, rebuildOnChange: true);

    return SizedBox.expand(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        color: model.backgroundColor,
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: SongDisplay(
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
