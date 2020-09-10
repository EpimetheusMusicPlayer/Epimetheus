import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AlbumArtDisplay extends StatefulWidget {
  final void Function(double page) onPositionChanged;
  final int initialPage;

  AlbumArtDisplay({
    @required this.onPositionChanged,
    this.initialPage = 0,
  });

  @override
  _AlbumArtDisplayState createState() => _AlbumArtDisplayState();
}

class _AlbumArtDisplayState extends State<AlbumArtDisplay> {
  PageController _controller;
  int _selected;

  StreamSubscription<MediaItem> _currentMediaItemSubscription;

  @override
  void initState() {
    super.initState();

    _selected = widget.initialPage;

    _controller = PageController(
      initialPage: widget.initialPage,
      viewportFraction: 0.8,
    )..addListener(
        () {
          widget.onPositionChanged(_controller.page);
          final rounded = _controller.page.round();
          if (_selected != rounded) {
            setState(() {
              _selected = rounded;
            });
          }
        },
      );

    int oldIndex = widget.initialPage;
    _currentMediaItemSubscription = AudioService.currentMediaItemStream.listen((mediaItem) async {
      final newIndex = AudioService.queue.indexOf(mediaItem);
      if (mounted) _controller.animateToPage(_controller.page.toInt() + (newIndex - oldIndex), duration: const Duration(milliseconds: 200), curve: Curves.decelerate);
      oldIndex = newIndex;
    });
  }

  @override
  void dispose() {
    _currentMediaItemSubscription.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MediaItem>>(
      stream: AudioService.queueStream,
      initialData: AudioService.queue,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        return ScrollConfiguration(
          behavior: const NoGlowScrollBehaviour(),
          child: Center(
            child: PageView(
              controller: _controller,
              children: [
                for (int i = 0; i < snapshot.data.length; ++i)
                  _SongTile(
                    mediaItem: snapshot.data[i],
                    selected: _selected == i,
                    // maxHeight: MediaQuery.of(context).size.height / 3,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SongTile extends StatelessWidget {
  final MediaItem mediaItem;
  final bool selected;
  final double maxHeight;

  _SongTile({
    @required this.mediaItem,
    @required this.selected,
    this.maxHeight = 0,
  }) : assert(maxHeight != null);

  @override
  Widget build(BuildContext context) {
    final containerLength = selected ? MediaQuery.of(context).size.width * 0.8 : MediaQuery.of(context).size.width * 0.75;

    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: containerLength,
        // height: containerLength,
        // height: containerLength < maxHeight ? containerLength : maxHeight,
        height: double.infinity,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: containerLength),
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 100),
            padding: EdgeInsets.symmetric(vertical: selected ? 32 : 32 * 1.06),
            child: Material(
              color: Colors.transparent,
              elevation: selected ? 8 : 2,
              child: CachedNetworkImage(
                imageUrl: mediaItem.artUri,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NoGlowScrollBehaviour extends ScrollBehavior {
  const NoGlowScrollBehaviour();

  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) => child;
}
