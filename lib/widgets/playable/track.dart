import 'package:cached_network_image/cached_network_image.dart';
import 'package:epimetheus/libepimetheus/songs.dart';
import 'package:flutter/material.dart';

class TrackListTile extends StatelessWidget {
  final Track track;

  TrackListTile(this.track);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(track.title),
                Text(track.artistTitle),
                Text(track.albumTitle),
              ],
            ),
          ),
          Text('${(track.duration / 60).floor()}:${track.duration.remainder(60).toString().padLeft(2, '0')}'),
        ],
      ),
    );
  }

  static const separator = Divider(
    height: 0,
    indent: 88,
  );
}
