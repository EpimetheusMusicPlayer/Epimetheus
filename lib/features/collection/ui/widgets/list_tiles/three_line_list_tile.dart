import 'package:epimetheus/core/ui/widgets/art_list_tile_image.dart';
import 'package:epimetheus/core/ui/widgets/tags/explicit.dart';
import 'package:flutter/material.dart';

class ThreeLineListTile extends StatelessWidget {
  static const separator = Divider(
    height: 0,
    indent: 88,
  );

  final String? artUrl;
  final Widget line1;
  final Widget line2;
  final Widget line3;
  final EdgeInsetsGeometry padding;

  const ThreeLineListTile({
    required this.artUrl,
    required this.line1,
    required this.line2,
    required this.line3,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          ArtListTileImage(artUrl),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [line1, line2, line3],
            ),
          )
        ],
      ),
    );
  }
}

class ThreeLineMediaListTile extends StatelessWidget {
  final String? artUrl;
  final Widget line1;
  final Widget line2;
  final Widget line3;
  final Duration duration;
  final bool isExplicit;
  final VoidCallback? onPlayPress;

  const ThreeLineMediaListTile({
    required this.artUrl,
    required this.line1,
    required this.line2,
    required this.line3,
    required this.duration,
    required this.isExplicit,
    this.onPlayPress,
  });

  String _formatDuration() {
    final seconds = duration.inSeconds;
    return '${seconds ~/ 60}:${seconds.remainder(60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 16,
        bottom: 16,
        left: 16,
      ),
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            Expanded(
              child: ThreeLineListTile(
                padding: EdgeInsets.zero,
                artUrl: artUrl,
                line1: line1,
                line2: line2,
                line3: line3,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                if (isExplicit)
                  Expanded(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: const Explicit(),
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        _formatDuration(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            onPlayPress == null
                ? const SizedBox(width: 16)
                : IconButton(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    icon: const Icon(Icons.play_arrow_outlined),
                    tooltip: 'Play',
                    onPressed: onPlayPress,
                  ),
          ],
        ),
      ),
    );
  }
}
