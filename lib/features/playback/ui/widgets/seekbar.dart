import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

class Seekbar extends StatefulWidget {
  final MediaItem mediaItem;
  final Color foregroundColor;
  final bool showLabels;
  final String maxDurationString;

  Seekbar({
    Key? key,
    required this.mediaItem,
    required this.foregroundColor,
    required this.showLabels,
  })   : maxDurationString = _formatTime(mediaItem.duration ?? Duration.zero),
        super(key: key);

  static String _formatTime(Duration duration) {
    String twoDigits(int n) => n < 10 ? '0$n' : n.toString();

    final minutes = twoDigits(
        (duration.inMicroseconds ~/ Duration.microsecondsPerMinute)
            .remainder(Duration.minutesPerHour));
    final seconds = twoDigits(
        (duration.inMicroseconds ~/ Duration.microsecondsPerSecond)
            .remainder(Duration.secondsPerMinute));

    return '$minutes:$seconds';
  }

  @override
  _SeekbarState createState() => _SeekbarState();
}

class _SeekbarState extends State<Seekbar> {
  double _getSliderValueFromDuration(Duration duration) =>
      duration.inMilliseconds.toDouble();

  Duration _getDurationFromSliderValue(double value) =>
      Duration(milliseconds: value.toInt());

  double? _changeValue;

  Widget _buildSlider(double value) {
    final max = _getSliderValueFromDuration(widget.mediaItem.duration);

    return SizedBox(
      height: 24,
      child: SliderTheme(
        data: SliderThemeData(
          valueIndicatorColor: widget.foregroundColor,
          activeTrackColor: widget.foregroundColor,
          inactiveTrackColor: widget.foregroundColor,
          thumbShape: SliderComponentShape.noThumb,
          overlayColor: widget.foregroundColor.withAlpha(31),
          trackHeight: 0.5,
          trackShape: const SeekBarTrackShape(),
        ),
        child: Slider(
          min: 0,
          max: max,
          value: value > max ? 0 : value,
          onChangeStart: (value) => _changeValue = value,
          onChangeEnd: (value) async {
            await AudioService.seekTo(_getDurationFromSliderValue(value));
            if (mounted) {
              setState(() {
                _changeValue = null;
              });
            }
          },
          onChanged: (value) {
            setState(() {
              _changeValue = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildLabels(Duration duration) {
    final style = TextStyle(
      color: widget.foregroundColor,
      fontSize: 12,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(Seekbar._formatTime(duration), style: style),
        Text(widget.maxDurationString, style: style),
      ],
    );
  }

  Widget _buildSeekbar(Duration duration) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showLabels) _buildLabels(duration),
        _buildSlider(_getSliderValueFromDuration(duration)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _changeValue == null
        ? StreamBuilder<Duration>(
            stream: Stream<Duration>.periodic(
              const Duration(milliseconds: 200),
              (_) => AudioService.playbackState.currentPosition,
            ),
            initialData: AudioService.playbackState.currentPosition,
            builder: (context, snapshot) {
              return _buildSeekbar(snapshot.data ?? Duration.zero);
            },
          )
        : _buildSeekbar(_getDurationFromSliderValue(_changeValue!));
  }
}

class SeekBarTrackShape extends RoundedRectSliderTrackShape {
  const SeekBarTrackShape();

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackTop =
        offset.dy + (parentBox.size.height - sliderTheme.trackHeight!) / 2;
    return Rect.fromLTRB(
      0,
      trackTop,
      parentBox.size.width,
      trackTop + sliderTheme.trackHeight!,
    );
  }
}
