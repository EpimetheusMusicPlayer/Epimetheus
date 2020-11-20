import 'package:epimetheus/core/ui/widgets/playable.dart';
import 'package:epimetheus/core/ui/widgets/three_line_list_tile.dart';
import 'package:flutter/material.dart';

/// A generic [ThreeLineMediaListTile] wrapper that displays song data.
class TrackListTile<T> extends Playable<T> {
  final String name;
  final String artistName;
  final String albumName;
  final Duration duration;
  final bool isExplicit;
  final String? artUrl;

  TrackListTile(
    T item, {
    required this.name,
    required this.artistName,
    required this.albumName,
    required this.duration,
    required this.isExplicit,
    required this.artUrl,
    VoidCallback? onPlayPress,
  }) : super(
          item,
          onPlayPress: onPlayPress,
        );

  @override
  Widget build(BuildContext context) {
    return ThreeLineMediaListTile(
      artUrl: artUrl,
      line1: Text(
        name,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      line2: Text(
        artistName,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
      ),
      line3: Text(
        albumName,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontStyle: FontStyle.italic,
        ),
      ),
      duration: duration,
      isExplicit: isExplicit,
      onPlayPress: onPlayPress,
    );
  }

  static const separator = ThreeLineListTile.separator;
}
