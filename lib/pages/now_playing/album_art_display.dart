import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
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
  CarouselController _controller;
  int _selected;

  StreamSubscription<MediaItem> _currentMediaItemSubscription;

  @override
  void initState() {
    super.initState();

    _controller = CarouselController();
    _selected = widget.initialPage;

    _listenToPositionChanges();
  }

  @override
  void dispose() {
    _stopListeningToPositionChanges();
    super.dispose();
  }

  void _listenToPositionChanges() {
    int oldIndex = widget.initialPage;
    _currentMediaItemSubscription =
        AudioService.currentMediaItemStream.listen((mediaItem) async {
      final newIndex = AudioService.queue.indexOf(mediaItem);
      if (oldIndex == newIndex) return;
      if (mounted) {
        _controller.animateToPage(
          _selected + (newIndex - oldIndex),
          duration: const Duration(milliseconds: 200),
          curve: Curves.decelerate,
        );
      }
      oldIndex = newIndex;
    });
  }

  void _stopListeningToPositionChanges() {
    _currentMediaItemSubscription.cancel();
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
          // TODO sometimes an error can be thrown here upon switching between mobile and desktop layouts.
          child: CarouselSlider.builder(
            carouselController: _controller,
            options: CarouselOptions(
              initialPage: widget.initialPage,
              height: double.infinity,
              viewportFraction: 0.6,
              enableInfiniteScroll: false,
              enlargeCenterPage: true,
              enlargeStrategy: CenterPageEnlargeStrategy.scale,
              onScrolled: (position) {
                widget.onPositionChanged(position);
                final rounded = position.round();
                if (_selected != rounded) {
                  setState(() {
                    _selected = rounded;
                  });
                }
              },
            ),
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: _SongTile(
                  mediaItem: snapshot.data[index],
                  selected: _selected == index,
                  // maxHeight: MediaQuery.of(context).size.height / 3,
                ),
              );
            },
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
    return Center(
      child: Material(
        color: Colors.transparent,
        elevation: selected ? 8 : 2,
        child: AspectRatio(
          aspectRatio: 1,
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
  Widget buildViewportChrome(
          BuildContext context, Widget child, AxisDirection axisDirection) =>
      child;
}
