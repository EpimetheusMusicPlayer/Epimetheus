import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/models/color/color_model.dart';
import 'package:epimetheus/pages/now_playing/album_art_display.dart';
import 'package:epimetheus/pages/now_playing/media_controls.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NowPlayingContent extends StatefulWidget {
  final bool displayMobileLayout;

  const NowPlayingContent({@required this.displayMobileLayout});

  @override
  _NowPlayingContentState createState() => _NowPlayingContentState();
}

class _NowPlayingContentState extends State<NowPlayingContent> {
  static final _fadeGradient = LinearGradient(
    colors: [Colors.black, Colors.transparent],
    stops: [0.95, 1],
  );

  final int initialPage = AudioService.queue.indexOf(AudioService.currentMediaItem);
  ValueNotifier<double> _pageNotifier;

  @override
  initState() {
    super.initState();
    _pageNotifier = ValueNotifier<double>(initialPage.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    final model = ColorModel.of(context, rebuildOnChange: true);

    void onPositionChanged(double page) {
      _pageNotifier.value = page;
    }

    final albumArtDisplay = AlbumArtDisplay(
      onPositionChanged: onPositionChanged,
      initialPage: initialPage,
    );

    final songInfoDisplay = _SongInfoDisplay(
      initialPage: initialPage,
      pageNotifier: _pageNotifier,
    );

    return SizedBox.expand(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        color: model.dominantColor,
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: widget.displayMobileLayout
                    ? Column(
                        children: [
                          Expanded(child: albumArtDisplay),
                          Align(
                            alignment: Alignment.topLeft,
                            child: songInfoDisplay,
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Flexible(
                            flex: 3,
                            child: ShaderMask(
                              shaderCallback: (rect) {
                                return _fadeGradient.createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
                              },
                              blendMode: BlendMode.dstIn,
                              child: albumArtDisplay,
                            ),
                          ),
                          Flexible(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: songInfoDisplay,
                            ),
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

class _SongInfoDisplay extends AnimatedWidget {
  final int initialPage;

  const _SongInfoDisplay({
    @required this.initialPage,
    @required ValueNotifier<double> pageNotifier,
  }) : super(listenable: pageNotifier);

  bool _isCurrentMediaItem(double page) => page.round() == AudioService.queue.indexOf(AudioService.currentMediaItem);

  @override
  Widget build(BuildContext context) {
    final model = ColorModel.of(context, rebuildOnChange: true);

    final page = (listenable as ValueNotifier<double>).value;
    final curvedScrollFraction = Curves.easeInOut.transform(page - page.truncateToDouble()).abs();

    return Opacity(
      opacity: curvedScrollFraction <= 0.5 ? -curvedScrollFraction * 2 + 1 : curvedScrollFraction * 2 - 1,
      child: StreamBuilder<List<MediaItem>>(
        stream: AudioService.queueStream,
        initialData: AudioService.queue,
        builder: (context, snapshot) {
          if (!(snapshot?.data?.isNotEmpty == true)) {
            return const SizedBox();
          }

          return _isCurrentMediaItem(page)
              ? _CurrentSongInfoDisplay(
                  mediaItem: AudioService.currentMediaItem,
                  color: model.readableForegroundColor,
                )
              : _UpcomingSongInfoDisplay(
                  mediaItem: snapshot.data[page.round()],
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
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
          NowPlayingSeekBar(
            mediaItem: mediaItem,
            color: color ?? Colors.black38,
            horizontalPadding: 48,
          ),
        ],
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
    );
  }
}

class NowPlayingSeekBar extends StatefulWidget {
  final MediaItem mediaItem;
  final Color color;
  final double horizontalPadding;

  NowPlayingSeekBar({
    @required this.mediaItem,
    @required this.color,
    this.horizontalPadding = 0,
  });

  @override
  _NowPlayingSeekBarState createState() => _NowPlayingSeekBarState();
}

// TODO animate seekbar
class _NowPlayingSeekBarState extends State<NowPlayingSeekBar> {
  bool _useLocalSeekValue = false;
  double _localSeekValue;

  int _playerSeekValue = AudioService.playbackState.currentPosition.inMilliseconds;
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
            _playerSeekValue = AudioService.playbackState?.currentPosition?.inMilliseconds ?? 0;
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
    final max = (widget.mediaItem.duration?.inMilliseconds ?? 0).toDouble();
    final position = (_useLocalSeekValue ? _localSeekValue : (_playerSeekValue > max ? max : _playerSeekValue)).toDouble();

    return Stack(
      children: [
        SliderTheme(
          data: SliderThemeData(
            valueIndicatorColor: widget.color,
            activeTrackColor: widget.color,
            inactiveTrackColor: widget.color,
            thumbShape: SliderComponentShape.noThumb,
            overlayColor: widget.color.withAlpha(31),
            trackHeight: 0.5,
            trackShape: _SeekBarTrackShape(widget.horizontalPadding),
          ),
          child: Slider(
            value: position,
            max: max,
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
              await AudioService.seekTo(Duration(milliseconds: value.toInt()));

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
        Positioned.fill(
          bottom: -32,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
            child: ClipRect(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      formatTime(position.truncate()),
                      style: TextStyle(
                        color: widget.color,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      formatTime(widget.mediaItem.duration.inMilliseconds),
                      style: TextStyle(
                        color: widget.color,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SeekBarTrackShape extends RoundedRectSliderTrackShape {
  final double horizontalPadding;

  const _SeekBarTrackShape(this.horizontalPadding);

  @override
  Rect getPreferredRect({
    RenderBox parentBox,
    Offset offset = Offset.zero,
    SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackTop = offset.dy + (parentBox.size.height - sliderTheme.trackHeight) / 2;
    return Rect.fromLTRB(
      horizontalPadding,
      trackTop,
      parentBox.size.width - horizontalPadding,
      trackTop + sliderTheme.trackHeight,
    );
  }
}
