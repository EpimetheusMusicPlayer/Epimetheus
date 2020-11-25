import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:epimetheus/features/playback/ui/widgets/embedded_media_controls.dart';
import 'package:epimetheus/features/playback/ui/widgets/seekbar.dart';
import 'package:epimetheus/routes.dart';
import 'package:flutter/material.dart';

/// Displays the given [child] with media controls below (when the audio
/// service is running).
class MediaControlContainer extends StatelessWidget {
  final Widget child;

  const MediaControlContainer({
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
                (!runningSnapshot.data! || mediaItemSnapshot.data == null)) {
              return child;
            }

            return Column(
              children: [
                Expanded(child: child),
                _MediaControlBar(mediaItemSnapshot.data!),
              ],
            );
          },
        );
      },
    );
  }
}

class _MediaControlBar extends StatelessWidget {
  final MediaItem _mediaItem;

  _MediaControlBar(this._mediaItem);

  Widget _buildImagePlaceholder() {
    return Image.asset(
      'assets/music_note.png',
      width: 64,
      height: 64,
    );
  }

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
              ? _buildImagePlaceholder()
              : CachedNetworkImage(
                  imageUrl: _mediaItem.artUri,
                  width: 64,
                  height: 64,
                  placeholder: (context, url) => _buildImagePlaceholder(),
                ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _mediaItem.title,
                  textScaleFactor: 1.1,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _mediaItem.artist,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _mediaItem.album,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.fade,
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
      decoration: BoxDecoration(color: Theme.of(context).primaryColor),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context)!
                  .pushReplacementNamed(RouteNames.nowPlaying);
            },
            child: _buildMetadataDisplay(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Seekbar(
              mediaItem: _mediaItem,
              foregroundColor: const Color(0xEEFFFFFF),
              showLabels: false,
            ),
          ),
          const EmbeddedMediaControls(),
        ],
      ),
    );
  }
}
