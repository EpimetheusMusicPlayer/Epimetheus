import 'package:epimetheus/art_constants.dart';
import 'package:epimetheus/libepimetheus/songs.dart';
import 'package:epimetheus/widgets/art_image_widget.dart';
import 'package:flutter/material.dart' hide Feedback;
import 'package:flutter/material.dart' as prefix0;

const double _padding = 16;
const double _height = 96;

class FeedbackTileWidget extends StatefulWidget {
  final Feedback feedback;
  final bool first;
  final bool last;
  final Future<void> Function() delete;

  const FeedbackTileWidget({
    @required this.feedback,
    @required this.first,
    @required this.last,
    @required this.delete,
  });

  @override
  _FeedbackTileWidgetState createState() => _FeedbackTileWidgetState();
}

class _FeedbackTileWidgetState extends State<FeedbackTileWidget> {
  bool _ratingPending = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.first || widget.last ? _height + _padding / 2 : _height,
      padding: EdgeInsets.only(
        left: _padding,
        right: _padding,
        top: widget.first ? _padding : _padding / 2,
        bottom: widget.last ? _padding : _padding / 2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ArtImageWidget(
            widget.feedback.getArtUrl(serviceArtSize),
            _height,
          ),
          SizedBox(width: _padding),
          Expanded(
            child: Row(
              crossAxisAlignment: prefix0.CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.feedback.title,
                        textScaleFactor: 1.1,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        widget.feedback.artistTitle,
                        textScaleFactor: 1.1,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                      ),
                      SizedBox(height: 2),
                      Text(
                        widget.feedback.albumTitle,
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
                _ratingPending
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(IconTheme.of(context).color),
                            strokeWidth: 0.5,
                          ),
                        ),
                      )
                    : IconButton(
                        icon: Icon(Icons.close),
                        tooltip: 'Delete',
                        onPressed: () async {
                          setState(() {
                            _ratingPending = true;
                          });
                          await widget.delete();
                          setState(() {
                            _ratingPending = false;
                          });
                        },
                      )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
