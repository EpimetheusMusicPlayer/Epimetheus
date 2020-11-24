import 'package:epimetheus/core/ui/widgets/art_list_tile_image.dart';
import 'package:flutter/material.dart';
import 'package:iapetus/iapetus.dart';

class StationListTile extends StatelessWidget {
  final bool playing;
  final Station station;

  const StationListTile({
    Key? key,
    this.playing = false,
    required this.station,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: <Widget>[
          ArtListTileImage(
            station.art.recommendedUri?.toString(),
            playing: playing,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(station.name),
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
