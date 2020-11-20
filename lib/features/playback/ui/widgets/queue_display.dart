import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:epimetheus/features/playback/entities/audio_task_keys.dart';
import 'package:epimetheus/features/playback/entities/queue_display_item.dart';
import 'package:epimetheus/features/playback/ui/widgets/queue_carousel.dart';
import 'package:epimetheus/features/playback/ui/widgets/queue_display_selected_song_body.dart';
import 'package:epimetheus/features/playback/ui/widgets/queue_display_unselected_song_body.dart';
import 'package:flutter/material.dart';

class QueueDisplay extends StatefulWidget {
  final Color dominantColor;
  final bool isDominantColorDark;

  const QueueDisplay({
    Key? key,
    required this.dominantColor,
    required this.isDominantColorDark,
  }) : super(key: key);

  @override
  _QueueDisplayState createState() => _QueueDisplayState();
}

class _QueueDisplayState extends State<QueueDisplay> {
  final _queueStream = AudioService.queueStream
      .map<List<QueueDisplayItem>?>(QueueDisplayItem.mapQueue);
  final _carouselController = CarouselController();

  late final _initialIndex = _currentlyPlayingQueueIndex;

  late int _selectedIndex = _initialIndex;
  double _changeFraction = 0;

  /// The subscription used to listen to changes in the currently playing index.
  /// Assigned in [_startListening], and cancelled in [_stopListening].
  late final StreamSubscription<MediaItem> _subscription;

  static int get _currentlyPlayingQueueIndex =>
      AudioService.currentMediaItem!.extras[AudioTaskKeys.mediaItemIndex];

  /// Selects the given playing media item.
  void _selectPlayingMediaItem(MediaItem playingMediaItem) {
    final index = playingMediaItem.extras[AudioTaskKeys.mediaItemIndex];
    if (index == _selectedIndex) return;
    _carouselController.animateToPage(
      index,
      duration: const Duration(milliseconds: 200),
      curve: QueueCarousel.transitionCurve,
    );
  }

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

        _selectPlayingMediaItem(mediaItem);
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
    return StreamBuilder<List<QueueDisplayItem>?>(
      stream: _queueStream,
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
                    ? QueueDisplaySelectedSongBody(
                        queueItem: snapshot.data![_selectedIndex],
                        isDominantColorDark: widget.isDominantColorDark,
                      )
                    : QueueDisplayUnselectedSongBody(
                        playingMediaItem: AudioService.currentMediaItem,
                        selectedQueueItem: snapshot.data![_selectedIndex],
                        dominantColor: widget.dominantColor,
                        isDominantColorDark: widget.isDominantColorDark,
                        selectPlaying: () {
                          _selectPlayingMediaItem(
                              AudioService.currentMediaItem);
                        },
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
