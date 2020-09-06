import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:epimetheus/models/color/color_model.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class SongDisplay extends StatefulWidget {
  final void Function(int newPage) onPageChanged;

  SongDisplay(this.onPageChanged);

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
          if (_selected != page) {
            widget.onPageChanged(page);
            setState(() {
              _selected = page;
            });
          }
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

class _SongInfoText extends StatelessWidget {
  final MediaItem mediaItem;

  _SongInfoText(this.mediaItem);

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<ColorModel>(
      builder: (context, child, model) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 32,
          ),
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  mediaItem.title,
                  style: TextStyle(
                    color: model.readableForegroundColor,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class NoGlowScrollBehaviour extends ScrollBehavior {
  const NoGlowScrollBehaviour();

  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) => child;
}
