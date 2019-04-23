import 'package:epimetheus/libepimetheus/songs.dart';
import 'package:epimetheus/libepimetheus/stations.dart';
import 'package:epimetheus/models/model.dart';
import 'package:epimetheus/pages/feedback/feedback_tile_widget.dart';
import 'package:epimetheus/widgets/app_bar_title_subtitle_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Feedback;
import 'package:paging/paging.dart';

class FeedbackPage extends StatefulWidget {
  final String stationName;
  final String stationId;

  const FeedbackPage({
    @required this.stationName,
    @required this.stationId,
  });

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

// TODO do this
class _FeedbackPageState extends State<FeedbackPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 1,
      child: Scaffold(
        appBar: AppBar(
          title: AppBarTitleSubtitleWidget('Feedback', widget.stationName),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.thumb_down),
                text: 'Banned',
              ),
              Tab(
                icon: Icon(Icons.thumb_up),
                text: 'Loved',
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: DefaultTabController.of(context),
          children: <Widget>[
            FeedbackTabContent(
              stationId: widget.stationId,
              positive: false,
            ),
            FeedbackTabContent(
              stationId: widget.stationId,
              positive: true,
            ),
          ],
        ),
      ),
    );
  }
}

class FeedbackTabContent extends StatefulWidget {
  final String stationId;
  final bool positive;

  FeedbackTabContent({
    @required this.stationId,
    @required this.positive,
  });

  @override
  _FeedbackTabContentState createState() => _FeedbackTabContentState();
}

class _FeedbackTabContentState extends State<FeedbackTabContent> with AutomaticKeepAliveClientMixin<FeedbackTabContent> {
  bool _loaded = false;
  int _totalFeedbackItems;

  @override
  bool get wantKeepAlive => true;

  Future<FeedbackListSegment> getFeedback({int pageSize = 30, int startIndex = 0}) async {
    return await Station.getFeedback(
      user: EpimetheusModel.of(context).user,
      stationId: widget.stationId,
      positive: widget.positive,
      pageSize: pageSize,
      startIndex: startIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: <Widget>[
        Pagination<Feedback>(
          pageBuilder: (currentSize) async {
            if (currentSize == _totalFeedbackItems) return const [];
            final segment = await getFeedback(
              startIndex: currentSize,
            );
            _totalFeedbackItems = segment.total;
            if (!_loaded) {
              setState(() {
                _loaded = true;
              });
            }
            return segment.segment;
          },
          itemBuilder: (index, currentListSize, feedback) {
            return FeedbackTileWidget(
              feedback: feedback,
              first: index == 0,
              last: index == currentListSize - 1,
            );
          },
          progress: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                  strokeWidth: 1,
                ),
              ),
//              child: const Text('Loading more...'),
            ),
          ),
        ),
        if (!_loaded)
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
          ),
        if (!_loaded)
          Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
            ),
          ),
      ],
    );
  }
}
