import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:epimetheus/features/playback/entities/audio_task_keys.dart';
import 'package:epimetheus/features/playback/entities/queue_display_item.dart';
import 'package:epimetheus/features/playback/ui/widgets/queue_carousel.dart';
import 'package:epimetheus/features/playback/ui/widgets/queue_display_song_controls.dart';
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
  static const _carouselSkipDurationMillis = 200;

  final _queueStream = AudioService.queueStream
      .map<List<QueueDisplayItem>?>(QueueDisplayItem.mapQueue);
  final _carouselController = CarouselController();

  late final _initialIndex = _currentlyPlayingQueueIndex;

  late int _selectedIndex = _initialIndex;
  double _changeFraction = 0;

  /// True if the carousel is in the middle of skipping based on an event from
  /// the audio service.
  bool _isSkipping = false;

  /// The subscription used to listen to changes in the currently playing index.
  /// Assigned in [_startListening], and cancelled in [_stopListening].
  late final StreamSubscription<MediaItem> _subscription;

  static int get _currentlyPlayingQueueIndex => AudioService.currentMediaItem!
      .extras[AudioTaskMetadataKeys.currentlyPlayingQueueIndex];

  /// Selects the given playing media item.
  void _selectIndex(int index) {
    _carouselController.animateToPage(
      index,
      duration: const Duration(milliseconds: _carouselSkipDurationMillis),
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

        // Do nothing if the new index is already selected.
        final index =
            mediaItem.extras[AudioTaskMetadataKeys.currentlyPlayingQueueIndex];
        if (index == _selectedIndex) return;

        // Set _isSkipping to true, and change it back halfway through the
        // carousel transition.
        // This results in the old item showing the controls until it fades out
        // halfway through the transition, instead of jarringly changing to the
        // return chip before transitioning.
        //
        // Setting the state isn't needed, as the value is accessed every frame
        // during a build invoked by a gesture.
        _isSkipping = true;
        Future.delayed(
                const Duration(milliseconds: _carouselSkipDurationMillis ~/ 2))
            .then((_) => _isSkipping = false);

        _selectIndex(index);
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
        final transitionOpacity =
            Curves.easeOut.transform(1 - _changeFraction.abs());

        // Keep the old item selected until the skip finishes completely.
        final uiCurrentlyPlayingQueueIndex = (_isSkipping
            ? _currentlyPlayingQueueIndex - 1
            : _currentlyPlayingQueueIndex);

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
              child: QueueDisplaySongControls(
                selected: _selectedIndex == uiCurrentlyPlayingQueueIndex,
                isSelectedChanging:
                    (uiCurrentlyPlayingQueueIndex == _selectedIndex &&
                            _changeFraction != 0) ||
                        (uiCurrentlyPlayingQueueIndex == _selectedIndex - 1 &&
                            _changeFraction < 0) ||
                        (uiCurrentlyPlayingQueueIndex == _selectedIndex + 1 &&
                            _changeFraction > 0),
                transitionOpacity: transitionOpacity,
                playingMediaItem: AudioService.currentMediaItem,
                selectedQueueItem: snapshot.data![_selectedIndex],
                dominantColor: widget.dominantColor,
                isDominantColorDark: widget.isDominantColorDark,
                selectPlaying: () {
                  _selectIndex(
                    AudioService.currentMediaItem.extras[
                        AudioTaskMetadataKeys.currentlyPlayingQueueIndex],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
