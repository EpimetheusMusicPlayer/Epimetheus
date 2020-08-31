import 'package:epimetheus/audio/launch_helpers.dart';
import 'package:epimetheus/libepimetheus/stations.dart';
import 'package:epimetheus/widgets/misc/art_displays.dart';
import 'package:flutter/material.dart';

class StationListTile extends StatelessWidget {
  final Station station;
  final int index;

  StationListTile(this.station, this.index);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => launchStation(context, index),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            ArtListTileImage(station.getArtUrl(500)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(station.title),
            ),
          ],
        ),
      ),
    );
  }

  static const separator = const Divider(
    height: 0,
    indent: 88,
  );
}

// class _StationListTileArt extends StatelessWidget {
//   final Station station;
//
//   _StationListTileArt(this.station);
//
//   @override
//   Widget build(BuildContext context) {
//     final image = ArtListTileImage(station.getArtUrl(500));
//
//     // The thumbprint icon has SVG rings around it. The SVG is pulled directly from the Pandora web app.
//     // Disabled for now because it looks like garbage.
// //    if (station.isThumbprint) {
// //      return Stack(
// //        children: <Widget>[
// //          SvgPicture.asset(
// //            'assets/thumbprint.svg',
// //            width: 56,
// //          ),
// //          image,
// //        ],
// //      );
// //    }
//
//     return image;
//   }
// }
