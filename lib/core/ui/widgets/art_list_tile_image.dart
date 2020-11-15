// import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// TODO CachedNetworkImage doesn't work with null-safety yet;
// this is a temporary implementation.
// class ArtListTileImage extends StatelessWidget {
//   final String? artUrl;
//
//   const ArtListTileImage(this.artUrl);
//
//   @override
//   Widget build(BuildContext context) {
//     if (artUrl == null) {
//       return Image.asset(
//         'assets/music_note.png',
//         width: 56,
//         height: 56,
//         fit: BoxFit.cover,
//         alignment: Alignment.center,
//       );
//     } else {
//       return FadeInImage.assetNetwork(
//         placeholder: 'assets/music_note.png',
//         image: artUrl!,
//         width: 56,
//         height: 56,
//         fit: BoxFit.cover,
//         alignment: Alignment.center,
//       );
//     }
//   }
// }

class ArtListTileImage extends StatelessWidget {
  final String? artUrl;

  const ArtListTileImage(this.artUrl);

  @override
  Widget build(BuildContext context) {
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
}
