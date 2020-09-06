import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AlbumArtDisplay extends StatefulWidget {
  final void Function(int newPage) onPageChanged;
  int initialPage;

  AlbumArtDisplay({
    @required this.onPageChanged,
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
          final page = _controller.page.round();
          if (_selected != page) {
            widget.onPageChanged(page);
            setState(() {
              _selected = page;
            });
          }
        },
      );

    int oldIndex = widget.initialPage;
    _currentMediaItemSubscription = AudioService.currentMediaItemStream.listen((mediaItem) async {
      final newIndex = AudioService.queue.indexOf(mediaItem);
      if (mounted) _controller.animateToPage(_controller.page.toInt() + (newIndex - oldIndex), duration: const Duration(milliseconds: 500), curve: Curves.decelerate);
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
    final tiles = <Widget>[];

    return StreamBuilder<List<MediaItem>>(
      stream: AudioService.queueStream,
      initialData: AudioService.queue,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        for (int i = 0; i < snapshot.data.length; ++i) {
          tiles.add(
            _SongTile(
              mediaItem: snapshot.data[i],
              selected: _selected == i,
            ),
          );
        }

        return ScrollConfiguration(
          behavior: const NoGlowScrollBehaviour(),
          child: SizedBox(
            height: MediaQuery.of(context).size.width,
            child: Center(
              child: PageView(
                controller: _controller,
                children: tiles,
              ),
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

  _SongTile({
    @required this.mediaItem,
    @required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final containerLength = selected ? MediaQuery.of(context).size.width * 0.8 : MediaQuery.of(context).size.width * 0.75;

    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: containerLength,
        height: containerLength,
        child: Material(
          color: Colors.transparent,
          elevation: selected ? 8 : 2,
          child: CachedNetworkImage(
            imageUrl: mediaItem.artUri,
            fit: BoxFit.cover,
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
