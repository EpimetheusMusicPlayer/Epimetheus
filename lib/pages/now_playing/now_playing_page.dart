import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/audio/audio_task.dart';
import 'package:epimetheus/audio/music_provider.dart';
import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:epimetheus/pages/now_playing/song_tile_widget.dart';
import 'package:epimetheus/widgets/app_bar_title_subtitle_widget.dart';
import 'package:epimetheus/widgets/media_control_widget.dart';
import 'package:epimetheus/widgets/navigation_drawer_widget.dart';
import 'package:flutter/material.dart';

class NowPlayingPage extends StatefulWidget {
  final User _user;
  final MusicProvider _musicProvider;

  NowPlayingPage([this._user, this._musicProvider]);

  @override
  _NowPlayingPageState createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage> with WidgetsBindingObserver {
  ScrollController _scrollController;
  bool _elevated;
  MusicProviderType _musicProviderType;
  String _musicProviderId;
  String _musicProviderName;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_elevated != (_scrollController.hasClients && _scrollController.offset != 0)) setState(() {});
    });
    if (widget._user != null && widget._musicProvider != null) launchMusicProvider(widget._user, widget._musicProvider);
    if (widget._musicProvider != null) {
      _musicProviderType = widget._musicProvider.type;
      _musicProviderId = widget._musicProvider.id;
      _musicProviderName = widget._musicProvider.title;
    } else if (AudioService.currentMediaItem != null) {
      final data = AudioService.currentMediaItem.genre.split('||');
      assert(data.length < 4, 'To many data segments!');
      switch (data[0]) {
        case 'station':
          _musicProviderType = MusicProviderType.station;
          break;
      }
      _musicProviderId = data[1];
      _musicProviderName = data[2];
    } else {
      _musicProviderName = 'Nothing playing.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitleSubtitleWidget('Now Playing', _musicProviderName),
        elevation: (_elevated = (_scrollController.hasClients && _scrollController.offset != 0)) ? 4 : 0,
        actions: _musicProviderId != null && _musicProviderType == MusicProviderType.station
            ? <Widget>[
                IconButton(
                  icon: Icon(Icons.thumbs_up_down),
                  tooltip: 'Station feedback',
                  onPressed: () {
                    openFeedbackPage(context, _musicProviderName, _musicProviderId);
                  },
                )
              ]
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
