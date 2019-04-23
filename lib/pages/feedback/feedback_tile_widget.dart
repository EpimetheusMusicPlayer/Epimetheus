import 'package:epimetheus/art_constants.dart';
import 'package:epimetheus/libepimetheus/songs.dart';
import 'package:epimetheus/widgets/art_image_widget.dart';
import 'package:flutter/material.dart' hide Feedback;

const double _padding = 16;
const double _height = 96;

class FeedbackTileWidget extends StatelessWidget {
  final Feedback feedback;
  final bool first;
  final bool last;

  const FeedbackTileWidget({
    @required this.feedback,
    @required this.first,
    @required this.last,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: first || last ? _height + _padding / 2 : _height,
      padding: EdgeInsets.only(
        left: _padding,
        right: _padding,
        top: first ? _padding : _padding / 2,
        bottom: last ? _padding : _padding / 2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ArtImageWidget(
            feedback.getArtUrl(serviceArtSize),
            _height,
          ),
          SizedBox(width: _padding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feedback.title,
                  textScaleFactor: 1.1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  feedback.artistTitle,
                  textScaleFactor: 1.1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
                SizedBox(height: 2),
                Text(
                  feedback.albumTitle,
                  textScaleFactor: 1.1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: TextStyle(
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
