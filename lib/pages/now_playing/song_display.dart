import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:epimetheus/models/color/color_model.dart';
import 'package:flutter/material.dart';

class SongDisplay extends StatefulWidget {
  @override
  _SongDisplayState createState() => _SongDisplayState();
}

class _SongDisplayState extends State<SongDisplay> {
  PageController _controller;
  int _selected = 0;

  @override
  void initState() {
    super.initState();

    _controller = PageController(
      viewportFraction: 0.8,
    )..addListener(
        () {
          final page = _controller.page.round();
          if (_selected != page)
            setState(() {
              _selected = page;
            });
        },
      );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = ColorModel.of(context, rebuildOnChange: true);
    final tiles = <Widget>[];

    for (int i = 0; i < AudioService.queue.length; ++i) {
      tiles.add(
        _SongTile(
          mediaItem: AudioService.queue[i],
          selected: _selected == i,
          foregroundColor: model.readableForegroundColor,
        ),
      );
    }

    return ScrollConfiguration(
      behavior: const NoGlowScrollBehaviour(),
      child: PageView(
        controller: _controller,
        children: tiles,
      ),
    );
  }
}

class _SongTile extends StatelessWidget {
  final MediaItem mediaItem;
  final bool selected;
  final Color foregroundColor;

  _SongTile({
    @required this.mediaItem,
    @required this.selected,
    @required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            height: selected ? MediaQuery.of(context).size.width * 0.8 : MediaQuery.of(context).size.width * 0.75,
            child: Material(
              color: Colors.transparent,
              elevation: selected ? 8 : 2,
              child: CachedNetworkImage(
                imageUrl: mediaItem.artUri,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          mediaItem.title,
          style: TextStyle(
            color: foregroundColor,
          ),
        ),
        const SizedBox(
          height: 200,
        )
      ],
    );
  }
}

class NoGlowScrollBehaviour extends ScrollBehavior {
  const NoGlowScrollBehaviour();

  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) => child;
}
