import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class ArtTile extends StatelessWidget {
  final String artUrl;
  final String label;
  final double labelWidth;

  const ArtTile({
    @required this.artUrl,
    @required this.label,
    @required this.labelWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: FractionalOffset.topCenter,
              end: FractionalOffset.bottomLeft,
              colors: <Color>[
                Colors.transparent,
                Colors.black,
              ],
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: CachedNetworkImage(
              imageUrl: artUrl,
              placeholder: (context, url) => Image.asset(
                'assets/music_note.png',
                fit: BoxFit.cover,
              ),
              placeholderFadeInDuration: const Duration(milliseconds: 500),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          left: 16,
          child: SizedBox(
            width: labelWidth,
            child: Text(
              label,
              overflow: TextOverflow.fade,
              softWrap: false,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ArtTileCarousel extends StatelessWidget {
  final List<String> labels;
  final List<String> artUrls;
  final void Function(int index) onTap;

  const ArtTileCarousel({
    @required this.labels,
    @required this.artUrls,
    @required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      viewportFraction: 0.5,
      autoPlay: true,
      aspectRatio: (4 / 3) / 0.5,
      items: <Widget>[
        for (int i = 0; i < artUrls.length; i++)
          Card(
            clipBehavior: Clip.antiAlias,
            child: GestureDetector(
              onTap: () {
                onTap(i);
              },
              child: ArtTile(
                artUrl: artUrls[i],
                label: labels[i],
                labelWidth: 160,
              ),
            ),
          ),
      ],
    );
  }
}
