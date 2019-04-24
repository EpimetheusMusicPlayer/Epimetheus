import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/models/model.dart';
import 'package:epimetheus/pages/now_playing/song_tile_widget.dart';
import 'package:epimetheus/widgets/app_bar_title_subtitle_widget.dart';
import 'package:epimetheus/widgets/media_control_widget.dart';
import 'package:epimetheus/widgets/navigation_drawer_widget.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final model = EpimetheusModel.of(context);
    return Scaffold(
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
      body: StreamBuilder<List<MediaItem>>(
        initialData: AudioService.queue,
        stream: AudioService.queueStream,
        builder: (context, snapshot) {
          return Column(
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemBuilder: (context, index) {
                    return SongTileWidget(
                      mediaItem: snapshot.data[index],
                      index: index,
                      lastItemIndex: snapshot.data.length - 1,
                    );
                  },
                  itemCount: snapshot.hasData ? snapshot.data.length : 0,
                ),
              ),
              MediaControlWidget(false),
            ],
          );
        },
      ),
    );
  }
}
