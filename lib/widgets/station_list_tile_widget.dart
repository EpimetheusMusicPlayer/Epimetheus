import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/libepimetheus/stations.dart';
import 'package:epimetheus/models/model.dart';
import 'package:epimetheus/widgets/art_image_widget.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';

class StationListTile extends StatelessWidget {
  final Station _station;

  const StationListTile(this._station);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Row(
        children: [
          Hero(
            tag: _station.pandoraId + '/image',
            child: ArtImageWidget(
              _station.getArtUrl(130),
              56,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              _station.title,
            ),
          ),
          if (EpimetheusModel.of(context).currentMusicProvider != null)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: EpimetheusModel.of(context).currentMusicProvider.id == _station.stationId ? 0.75 : 0,
              child: _MediaPlayingAnimation(),
            ),
        ],
      ),
    );
  }
}

class _MediaPlayingAnimation extends StatelessWidget {
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: StreamBuilder<PlaybackState>(
        stream: AudioService.playbackStateStream,
        initialData: AudioService.playbackState,
        builder: (context, snapshot) {
          return FlareActor(
            'assets/media_playing.flr',
            animation: 'bars',
            isPaused: snapshot.data.basicState != BasicPlaybackState.playing,
          );
        },
      ),
    );
  }
}
