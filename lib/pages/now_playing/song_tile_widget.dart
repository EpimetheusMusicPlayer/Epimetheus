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
    final foregroundColor = index == 0 ? theme.primaryTextTheme.title.color : Colors.black;
    final foregroundAccentColor = index == 0 ? theme.accentColor : Colors.blue;
    return Container(
      height: index == 0 || index == lastItemIndex ? 128 + _padding / 2 : 128,
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
          Hero(
            tag: mediaItem.id + '/image',
            child: ArtImageWidget(
              mediaItem.artUri,
              128,
            ),
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
                    color: foregroundColor,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  mediaItem.artist,
                  textScaleFactor: 1.1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: TextStyle(color: foregroundColor),
                ),
                SizedBox(height: 2),
                Text(
                  mediaItem.album,
                  textScaleFactor: 1.1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: foregroundColor,
                  ),
                ),
                SizedBox(height: 2),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: index == 0 ? ProgressWidget() : Container(),
                    ),
                    IconButton(
                      icon: Transform.translate(
                        offset: Offset(0, 2.7),
                        child: Icon(Icons.thumb_down),
                      ),
                      tooltip: 'Ban',
                      color: mediaItem.rating.isRated() && !mediaItem.rating.isThumbUp() ? foregroundAccentColor : foregroundColor,
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Transform.translate(
                        offset: const Offset(0, -2.7),
                        child: Icon(Icons.thumb_up),
                      ),
                      tooltip: 'Love',
                      color: mediaItem.rating.isRated() && mediaItem.rating.isThumbUp() ? foregroundAccentColor : foregroundColor,
                      onPressed: () {},
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
