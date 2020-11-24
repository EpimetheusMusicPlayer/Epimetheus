import 'package:cached_network_image/cached_network_image.dart';
import 'package:epimetheus_nullable/mobx/playback/playback_store.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

class ArtListTileImage extends StatelessWidget {
  final String? artUrl;
  final bool playing;

  const ArtListTileImage(this.artUrl, {this.playing = false});

  Widget _buildImageWidget() {
    if (artUrl == null) {
      return Image.asset(
        'assets/music_note.png',
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        alignment: Alignment.center,
      );
    } else {
      return CachedNetworkImage(
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        imageUrl: artUrl!,
        placeholder: (context, imageUrl) => Image.asset(
          'assets/music_note.png',
          height: 56,
        ),
        placeholderFadeInDuration: const Duration(milliseconds: 500),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return playing
        ? SizedBox(
            width: 56,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                _buildImageWidget(),
                SizedBox(
                  height: 28,
                  child: Observer(
                    builder: (context) {
                      final Color? color =
                          GetIt.instance<PlaybackStore>().dominantColor;
                      return FlareActor(
                        'assets/media_playing.flr',
                        animation: 'bars',
                        color: color?.withAlpha(250) ?? Colors.white54,
                        fit: BoxFit.fill,
                      );
                    },
                  ),
                ),
              ],
            ),
          )
        : _buildImageWidget();
  }
}
