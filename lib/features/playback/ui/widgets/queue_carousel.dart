import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';

class QueueCarousel extends StatelessWidget {
  static const _imageShrinkFraction = 0.95;

  final bool isDominantColorDark;

  const QueueCarousel({
    Key? key,
    required this.isDominantColorDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MediaItem>>(
      stream: AudioService.queueStream,
      builder: (context, snapshot) {
        if (snapshot.data == null || snapshot.data!.isEmpty) {
          return const SizedBox();
        }

        final windowSize = MediaQuery.of(context).size;
        final imageSize = windowSize.shortestSide / 1.5;

        return ScrollSnapList(
          itemSize: imageSize,
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: snapshot.data![index].artUri,
              width: imageSize,
            );
          },
          onItemFocus: (index) {},
          focusOnItemTap: false,
          dynamicItemSize: true,
          dynamicSizeEquation: (distance) {
            final relativeDistance = distance.abs() * 2;
            if (relativeDistance > imageSize) return _imageShrinkFraction;
            return (relativeDistance * (_imageShrinkFraction - 1)) / imageSize +
                1;
          },
        );
      },
    );
  }
}
