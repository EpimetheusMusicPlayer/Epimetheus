import 'package:cached_network_image/cached_network_image.dart';
import 'package:epimetheus/libepimetheus/stations.dart';
import 'package:flutter/material.dart';

class StationListTile extends StatelessWidget {
  final Station station;

  StationListTile(this.station);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: <Widget>[
          CachedNetworkImage(
            height: 56,
            imageUrl: station.getArtUrl(500),
            placeholder: (context, imageUrl) => Image.asset(
              'assets/music_note.png',
              height: 56,
            ),
            placeholderFadeInDuration: const Duration(milliseconds: 500),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(station.title),
          ),
        ],
      ),
    );
  }

  static const separator = Divider(
    height: 0,
    indent: 88,
  );
}
