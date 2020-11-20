import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:epimetheus/features/playback/services/audio_task/audio_task.dart';
import 'package:epimetheus/features/playback/ui/widgets/queue_carousel.dart';
import 'package:epimetheus/features/playback/ui/widgets/queue_display_song_controls.dart';
import 'package:epimetheus/features/playback/ui/widgets/queue_display_song_info.dart';
import 'package:flutter/material.dart';

class QueueDisplay extends StatefulWidget {
  final bool isDominantColorDark;

  const QueueDisplay({
    Key? key,
    required this.isDominantColorDark,
  }) : super(key: key);

  @override
  _QueueDisplayState createState() => _QueueDisplayState();
}

class _QueueDisplayState extends State<QueueDisplay> {
  final _carouselController = CarouselController();

  late final _initialIndex = _currentlyPlayingQueueIndex;

  late int _selectedIndex = _initialIndex;
  double _changeFraction = 0;

  /// The subscription used to listen to changes in the currently playing index.
  /// Assigned in [_startListening], and cancelled in [_stopListening].
  late final StreamSubscription<MediaItem> _subscription;

  static int get _currentlyPlayingQueueIndex =>
      AudioService.currentMediaItem!.extras[AudioTask.mediaItemIndexKey];

  /// Starts listening to changes in the currently playing index.
  void _startListening() {
    _subscription = AudioService.currentMediaItemStream.listen(
      (MediaItem? mediaItem) {
        if (mediaItem == null) {
          // Navigate back to the collection page when the service ends.
          // Disabled because there's also a null mediaItem pushed when the
          // service starts.
          // Navigator.of(context)!.pushReplacementNamed(RouteNames.collection);
          return;
        }

        final index = mediaItem.extras[AudioTask.mediaItemIndexKey];
        if (index == _selectedIndex) return;
        _carouselController.animateToPage(
          index,
          duration: const Duration(milliseconds: 200),
          curve: QueueCarousel.transitionCurve,
        );
      },
    );
  }

  /// Stops what was started in [_startListening].
  void _stopListening() {
    _subscription.cancel();
  }

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  @override
  void dispose() {
    super.dispose();
    _stopListening();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MediaItem>>(
      stream: AudioService.queueStream,
      builder: (context, snapshot) {
        if (snapshot.data == null || snapshot.data!.isEmpty) {
          return const SizedBox();
        }

        final imageHeight = MediaQuery.of(context).size.shortestSide / 1.5;

        return Column(
          children: [
            SizedBox(
              height: imageHeight + 64,
              child: QueueCarousel(
                carouselController: _carouselController,
                queue: snapshot.data!,
                imageHeight: imageHeight,
                initialIndex: _initialIndex,
                selectedIndex: _selectedIndex,
                changeFraction: _changeFraction,
                onIndexSelected: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                onChangeFractionUpdated: (fraction) {
                  setState(() {
                    _changeFraction = fraction;
                  });
                },
              ),
            ),
            Expanded(
              child: Opacity(
                opacity: Curves.easeOut.transform(1 - _changeFraction.abs()),
                child: _selectedIndex == _currentlyPlayingQueueIndex
                    ? QueueDisplaySongControls(
                        mediaItem: snapshot.data![_selectedIndex],
                        isDominantColorDark: widget.isDominantColorDark,
                      )
                    : QueueDisplaySongInfo(
                        mediaItem: snapshot.data![_selectedIndex],
                        isDominantColorDark: widget.isDominantColorDark,
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
