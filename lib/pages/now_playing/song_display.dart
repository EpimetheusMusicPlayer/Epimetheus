import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class SongDisplay extends StatelessWidget {
  final List<MediaItem> queue;

  SongDisplay({@required this.queue});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 64),
          child: CachedNetworkImage(
            imageUrl: queue[0].artUri,
          ),
        ),
        SizedBox(height: 32),
        Text(queue[0].title),
      ],
    );
  }
}
