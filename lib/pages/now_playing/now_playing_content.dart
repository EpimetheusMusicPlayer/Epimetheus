import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/models/color/color_model.dart';
import 'package:epimetheus/pages/now_playing/album_art_display.dart';
import 'package:epimetheus/pages/now_playing/media_controls.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class NowPlayingContent extends StatefulWidget {
  @override
  _NowPlayingContentState createState() => _NowPlayingContentState();
}

class _NowPlayingContentState extends State<NowPlayingContent> {
  int page = 0;

  @override
  Widget build(BuildContext context) {
    final model = ColorModel.of(context, rebuildOnChange: true);

    void onPageChanged(int newPage) {
      setState(() {
        page = newPage;
      });
    }

    return SizedBox.expand(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        color: model.backgroundColor,
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    AlbumArtDisplay(onPageChanged),
                    _SongInfoDisplay(
                      page: page,
                    ),
                  ],
                ),
              ),
              EmbeddedMediaControls(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SongInfoDisplay extends StatefulWidget {
  final int page;

  _SongInfoDisplay({
    @required this.page,
  });

  @override
  __SongInfoDisplayState createState() => __SongInfoDisplayState();
}

class __SongInfoDisplayState extends State<_SongInfoDisplay> with SingleTickerProviderStateMixin {
  AnimationController _fadeController;
  bool firstPage = true;

  // Have a stateful page variable to update halfway through the animation.
  int page = 0;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      value: 1,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_SongInfoDisplay oldWidget) {
    final firstPage = (widget.page == 0);

    if ((oldWidget.page == 0) != firstPage) {
      _fadeController.reverse().then((_) {
        setState(() {
          this.firstPage = firstPage;
          page = widget.page;
        });

        _fadeController.forward();
      });
    } else {
      page = widget.page;
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final model = ColorModel.of(context, rebuildOnChange: true);

    return FadeTransition(
      opacity: _fadeController,
      child: StreamBuilder<List<MediaItem>>(
        stream: AudioService.queueStream,
        initialData: AudioService.queue,
        builder: (context, snapshot) {
          if (!(snapshot?.data?.isNotEmpty == true)) {
            return const SizedBox();
          }

          return firstPage
              ? _CurrentSongInfoDisplay(
                  mediaItem: snapshot.data[0],
                  color: model.readableForegroundColor,
                )
              : _UpcomingSongInfoDisplay(
                  mediaItem: snapshot.data[page],
                  color: model.readableForegroundColor,
                );
        },
      ),
    );
  }
}

class _CurrentSongInfoDisplay extends StatelessWidget {
  final MediaItem mediaItem;
  final Color color;

  _CurrentSongInfoDisplay({
    @required this.mediaItem,
    @required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 48,
        vertical: 32,
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              mediaItem.title,
              textScaleFactor: 1.3,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              mediaItem.artist,
              textScaleFactor: 1.2,
              style: TextStyle(
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              mediaItem.album,
              textScaleFactor: 1.2,
              style: TextStyle(
                color: color,
                fontStyle: FontStyle.italic,
              ),
            ),
            SeekBar(
              mediaItem: mediaItem,
              color: color,
            ),
          ],
        ),
      ),
    );
    ;
  }
}

class _UpcomingSongInfoDisplay extends StatelessWidget {
  final MediaItem mediaItem;
  final Color color;

  _UpcomingSongInfoDisplay({
    @required this.mediaItem,
    @required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 48,
        vertical: 32,
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              mediaItem.title,
              textScaleFactor: 1.3,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              mediaItem.artist,
              textScaleFactor: 1.2,
              style: TextStyle(
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              mediaItem.album,
              textScaleFactor: 1.2,
              style: TextStyle(
                color: color,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SeekBar extends StatefulWidget {
  final MediaItem mediaItem;
  final Color color;

  SeekBar({
    @required this.mediaItem,
    @required this.color,
  });

  @override
  _SeekBarState createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  bool _useLocalSeekValue = false;
  double _localSeekValue;

  double _playerSeekValue = AudioService.playbackState.currentPosition.toDouble();
  Timer _playerSeekValueTimer;

  String formatTime(int milliseconds) {
    String twoDigits(int n) => n < 10 ? '0$n' : n.toString();

    final minutes = twoDigits((milliseconds ~/ Duration.millisecondsPerMinute).remainder(Duration.minutesPerHour));
    final seconds = twoDigits((milliseconds ~/ Duration.millisecondsPerSecond).remainder(Duration.secondsPerMinute));

    return '$minutes:$seconds';
  }

  @override
  void initState() {
    super.initState();
    _playerSeekValueTimer = Timer.periodic(
      const Duration(milliseconds: 200),
      (_) {
        if (mounted) {
          setState(() {
            _playerSeekValue = AudioService.playbackState.currentPosition?.toDouble() ?? 0;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _playerSeekValueTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final max = widget.mediaItem.duration?.toDouble() ?? 0;
    final position = _useLocalSeekValue ? _localSeekValue : (_playerSeekValue > max ? max : _playerSeekValue);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          formatTime(position.truncate()),
          style: TextStyle(
            color: widget.color,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: SliderTheme(
            data: SliderThemeData(
              trackShape: const _SeekBarTrackShape(),
              valueIndicatorColor: widget.color,
              activeTrackColor: widget.color,
              inactiveTrackColor: widget.color,
            ),
            child: Slider(
              value: position,
              max: max,
              activeColor: widget.color,
              onChangeStart: (value) {
                _localSeekValue = value;
                _useLocalSeekValue = true;
              },
              onChanged: (value) {
                print('onChanged, ${value}');
                setState(() {
                  _localSeekValue = value;
                });
              },
              onChangeEnd: (value) async {
                await AudioService.seekTo(value.toInt());

                // Switch to the player position after it changes
                Timer.periodic(
                  const Duration(milliseconds: 200),
                  (timer) {
                    if (AudioService.playbackState.currentPosition != value.toInt()) {
                      _useLocalSeekValue = false;
                      timer.cancel();
                    }
                  },
                );
              },
            ),
          ),
        ),
        Text(
          formatTime(widget.mediaItem.duration),
          style: TextStyle(
            color: widget.color,
          ),
        ),
      ],
    );
  }
}

class _SeekBarTrackShape extends RoundedRectSliderTrackShape {
  const _SeekBarTrackShape();

  @override
  Rect getPreferredRect({
    RenderBox parentBox,
    Offset offset = Offset.zero,
    SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    return Rect.fromLTWH(
      offset.dx,
      offset.dy,
      parentBox.size.width,
      sliderTheme.trackHeight,
    );
  }
}
