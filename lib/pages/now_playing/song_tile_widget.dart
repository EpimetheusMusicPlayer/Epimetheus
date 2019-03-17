import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/widgets/art_image_widget.dart';
import 'package:epimetheus/widgets/progress_widget.dart';
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
    final theme = Theme.of(context);
    return Container(
      height: index == 0 ? 128 + _padding / 2 : 128,
      padding: EdgeInsets.only(
        left: _padding,
        right: _padding,
        top: index == 0 ? _padding : _padding / 2,
        bottom: index == lastItemIndex ? _padding : _padding / 2,
      ),
      color: index == 0 ? theme.primaryColor : Colors.transparent,
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
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: index == 0 ? theme.primaryTextTheme.title.color : Colors.black,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  mediaItem.artist,
                  textScaleFactor: 1.1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: TextStyle(color: index == 0 ? theme.primaryTextTheme.title.color : Colors.black),
                ),
                SizedBox(height: 2),
                Text(
                  mediaItem.album,
                  textScaleFactor: 1.1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: index == 0 ? theme.primaryTextTheme.title.color : Colors.black,
                  ),
                ),
                index == 0
                    ? Expanded(
                        child: Row(
                          children: <Widget>[
                            ProgressWidget(),
                          ],
                        ),
                      )
                    : SizedBox(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
