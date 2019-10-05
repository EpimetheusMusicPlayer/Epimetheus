import 'package:cached_network_image/cached_network_image.dart';
import 'package:epimetheus/audio/launch_helpers.dart';
import 'package:epimetheus/libepimetheus/songs.dart';
import 'package:epimetheus/widgets/tags/explicit.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class TrackTextFormatting {
  static String formatMinutes(int minutes) => '${(minutes / 60).floor()}:${minutes.remainder(60).toString().padLeft(2, '0')}';
}

class TrackInfoText extends StatelessWidget {
  final String title;
  final String album;
  final String artist;

  const TrackInfoText({
    @required this.title,
    @required this.album,
    @required this.artist,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          artist,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          album,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

class TrackListTile extends StatelessWidget {
  final Track track;

  TrackListTile(this.track);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 16,
          top: 16,
          bottom: 16,
        ),
        child: Row(
          children: <Widget>[
            CachedNetworkImage(
              height: 56,
              imageUrl: track.getArtUrl(500),
              placeholder: (context, imageUrl) => Image.asset(
                'assets/music_note.png',
                height: 56,
              ),
              placeholderFadeInDuration: const Duration(milliseconds: 500),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TrackInfoText(
                title: track.title,
                album: track.albumTitle,
                artist: track.artistTitle,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                if (track.explicitness == TrackExplicitness.explicit)
                  Expanded(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: const Explicit(),
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        TrackTextFormatting.formatMinutes(track.duration),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              icon: const Icon(OMIcons.playArrow),
              tooltip: 'Play',
              onPressed: () => launchTrack(context, track),
            ),
          ],
        ),
      ),
    );
  }

  static const separator = Divider(
    height: 0,
    indent: 88,
  );
}
