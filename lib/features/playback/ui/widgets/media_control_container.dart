import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:epimetheus/features/playback/ui/widgets/embedded_media_controls.dart';
import 'package:epimetheus_nullable/mobx/playback/playback_store.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

/// Displays the given [child] with media controls below (when the audio
/// service is running).
class MediaControlContainer extends StatelessWidget {
  final Widget child;

  final _playbackStore = GetIt.instance<PlaybackStore>();

  MediaControlContainer({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        stream: AudioService.runningStream,
        builder: (context, runningSnapshot) {
          return StreamBuilder<MediaItem>(
              stream: AudioService.currentMediaItemStream,
              builder: (context, mediaItemSnapshot) {
                if ((!runningSnapshot.hasData || !mediaItemSnapshot.hasData) ||
                    (!runningSnapshot.data! ||
                        mediaItemSnapshot.data == null)) {
                  return child;
                }

                return Column(
                  children: [
                    Expanded(child: child),
                    _MediaControlBar(mediaItemSnapshot.data!),
                  ],
                );
              });
        });
  }
}

class _MediaControlBar extends StatelessWidget {
  MediaItem _mediaItem;

  _MediaControlBar(this._mediaItem);

  Widget _buildMetadataDisplay() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: 8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _mediaItem.artUri == null
              ? const SizedBox(width: 64, height: 64)
              : CachedNetworkImage(
                  imageUrl: _mediaItem.artUri,
                  width: 64,
                  height: 64,
                ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _mediaItem.title,
                  textScaleFactor: 1.1,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _mediaItem.artist,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _mediaItem.album,
                  style: const TextStyle(
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: Theme.of(context)!.primaryColor),
      child: Column(
        children: [
          _buildMetadataDisplay(),
          const EmbeddedMediaControls(),
        ],
      ),
    );
  }
}
