import 'package:epimetheus/libepimetheus/stations.dart';
import 'package:epimetheus/widgets/art_image_widget.dart';
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
        ],
      ),
    );
  }
}
