import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/widgets/art_image_widget.dart';
import 'package:flutter/material.dart';

const double _padding = 16;

class SongTileWidget extends StatelessWidget {
  final MediaItem mediaItem;
  final int index;
  final int lastItemIndex;

  SongTileWidget({
    @required this.mediaItem,
    @required this.index,
    @required this.lastItemIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: _padding,
        right: _padding,
        top: index == 0 ? _padding : _padding / 2,
        bottom: index == lastItemIndex ? _padding : _padding / 2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ArtImageWidget(
            mediaItem.artUri,
            128,
          ),
          SizedBox(width: _padding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mediaItem.title,
                  textScaleFactor: 1.1,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  mediaItem.artist,
                  textScaleFactor: 1.1,
                ),
                SizedBox(height: 2),
                Text(
                  mediaItem.album,
                  textScaleFactor: 1.1,
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
