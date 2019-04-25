import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/libepimetheus/songs.dart';
import 'package:epimetheus/libepimetheus/stations.dart';
import 'package:epimetheus/main.dart';
import 'package:epimetheus/models/model.dart';
import 'package:epimetheus/pages/feedback/feedback_tile_widget.dart';
import 'package:epimetheus/widgets/app_bar_title_subtitle_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Feedback;
import 'package:flutter_pagewise/flutter_pagewise.dart';

class FeedbackPage extends StatefulWidget {
  final Station station;

  const FeedbackPage(this.station);

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  @override
  Widget build(BuildContext context) {
    return EpimetheusThemedPage(
      child: DefaultTabController(
        length: 2,
        initialIndex: 1,
        child: Scaffold(
          appBar: AppBar(
            title: AppBarTitleSubtitleWidget('Feedback', widget.station.title),
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
                station: widget.station,
                positive: false,
              ),
              FeedbackTabContent(
                station: widget.station,
                positive: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeedbackTabContent extends StatefulWidget {
  final Station station;
  final bool positive;

  FeedbackTabContent({
    @required this.station,
    @required this.positive,
  });

  @override
  _FeedbackTabContentState createState() => _FeedbackTabContentState();
}

class _FeedbackTabContentState extends State<FeedbackTabContent> with AutomaticKeepAliveClientMixin<FeedbackTabContent> {
  PagewiseLoadController<Feedback> _pageLoadController;

  @override
  bool get wantKeepAlive => true;

  Future<FeedbackListSegment> getFeedback({int pageSize = 30, int startIndex = 0}) async {
    return await widget.station.getFeedback(
      user: EpimetheusModel.of(context).user,
      positive: widget.positive,
      pageSize: pageSize,
      startIndex: startIndex,
    );
  }

  @override
  void initState() {
    super.initState();
    _pageLoadController = PagewiseLoadController<Feedback>(
      pageSize: 30,
      pageFuture: (index) async => (await getFeedback(pageSize: 30, startIndex: index * 30)).segment,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PagewiseListView<Feedback>(
      pageLoadController: _pageLoadController,
      showRetry: false,
      itemBuilder: (context, feedback, index) {
        return FeedbackTileWidget(
          feedback: feedback,
          first: index == 0,
          last: index == _pageLoadController.loadedItems.length - 1,
          delete: () async {
            await _pageLoadController.loadedItems[index].deleteFeedback(EpimetheusModel.of(context).user);
            if (await AudioService.running) {
              AudioService.setRating(Rating.newUnratedRating(RatingStyle.thumbUpDown), {
                'index': AudioService.queue.indexWhere((mediaItem) => mediaItem.id == feedback.pandoraId),
                'update': true,
              });
            }
            if (mounted) {
              setState(() {
                _pageLoadController.loadedItems.removeAt(index);
              });
            }
          },
        );
      },
      loadingBuilder: (context) {
        return Center(
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
          ),
        );
      },
      noItemsFoundBuilder: (context) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: const Text(
              'No feedback.',
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
      errorBuilder: (context, error) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: <Widget>[
              const Text(
                  'An error has occured. Please make sure you\'re connected to the Internet and have a US IP address. If so, report it to the developer.'),
              const SizedBox(height: 16),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black12,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    error.toString(),
                    style: TextStyle(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
