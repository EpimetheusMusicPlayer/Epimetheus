import 'package:epimetheus/art_constants.dart';
import 'package:flutter/material.dart';

class ArtImageWidget extends StatelessWidget {
  final String image;
  final double height;

  const ArtImageWidget(this.image, this.height);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: artBorderRadius,
      child: DecoratedBox(
        decoration: BoxDecoration(color: artBackgroundColor),
        child: image != null
            ? FadeInImage.assetNetwork(
                placeholder: 'assets/music_note.png',
                image: image,
                height: height,
                fit: BoxFit.cover,
              )
            : SizedBox(),
      ),
    );
  }
}
