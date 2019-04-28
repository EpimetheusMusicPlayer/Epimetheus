import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/main.dart';
import 'package:epimetheus/models/model.dart';
import 'package:epimetheus/pages/now_playing/song_tile_widget.dart';
import 'package:epimetheus/widgets/app_bar_title_subtitle_widget.dart';
import 'package:epimetheus/widgets/media_control_widget.dart';
import 'package:epimetheus/widgets/navigation_drawer_widget.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class NowPlayingPage extends StatefulWidget {
  @override
  _NowPlayingPageState createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage> with WidgetsBindingObserver {
  ScrollController _scrollController;
  bool _elevated;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_elevated != (_scrollController.hasClients && _scrollController.offset != 0)) setState(() {});
    });
  }

//  Widget _itemBuilder(MediaItem mediaItem, int index, BuildContext context, Animation<double> animation) {
//    return SizeTransition(
//      sizeFactor: animation,
//      child: DecoratedBox(
//        decoration: BoxDecoration(color: index == 0 ? Theme.of(context).primaryColor : Colors.transparent),
//        child: FadeTransition(
//          opacity: animation,
//          child: SongTileWidget(
//            mediaItem: mediaItem,
//            index: index,
//            lastItemIndex: AudioService.queue.length - 1,
//          ),
//        ),
//      ),
//    );
//  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<EpimetheusModel>(
      rebuildOnChange: true,
      builder: (context, child, model) {
        return EpimetheusThemedPage(
          child: Scaffold(
            appBar: AppBar(
              title: AppBarTitleSubtitleWidget('Now Playing', model.currentMusicProvider?.title ?? 'Nothing playing.', () {
                Navigator.of(context).pushReplacementNamed('/station_list');
              }),
              elevation: (_elevated = (_scrollController.hasClients && _scrollController.offset != 0)) ? 4 : 0,
              actions: model.currentMusicProvider != null
                  ? model.currentMusicProvider.getActions(this).map((action) {
                      return IconButton(
                        icon: Icon(action.iconData),
                        tooltip: action.label,
                        onPressed: action.onTap,
                      );
                    }).toList(growable: false)
                  : null,
            ),
            drawer: const NavigationDrawerWidget('/now_playing'),
            body: child,
          ),
        );
      },
      child: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<List<MediaItem>>(
              stream: AudioService.queueStream,
              initialData: AudioService.queue,
              builder: (context, snapshot) {
                if (snapshot.data == null || snapshot.data.isEmpty) {
                  return const Center(child: const Text('Noting playing.'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      return SongTileWidget(
                        mediaItem: snapshot.data[index],
                        index: index,
                        lastItemIndex: snapshot.data.length - 1,
                      );
                    },
                  );
                }
              },
            ),
//            child: AnimatedStreamList<MediaItem>(
//              streamList: AudioService.queueStream,
//              initialList: AudioService.queue,
//              equals: (o1, o2) => false,
//              itemBuilder: _itemBuilder,
//              itemRemovedBuilder: _itemBuilder,
//            ),
          ),
          MediaControlWidget(false),
        ],
      ),
    );
  }
}
