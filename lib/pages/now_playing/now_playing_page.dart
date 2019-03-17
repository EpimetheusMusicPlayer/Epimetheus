import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/audio/audio_task.dart';
import 'package:epimetheus/audio/music_provider.dart';
import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:epimetheus/libepimetheus/networking.dart';
import 'package:epimetheus/pages/now_playing/song_tile_widget.dart';
import 'package:epimetheus/widgets/dynamic_app_bar.dart';
import 'package:epimetheus/widgets/media_control_widget.dart';
import 'package:epimetheus/widgets/navigation_drawer_widget.dart';
import 'package:flutter/material.dart';

class NowPlayingPage extends StatefulWidget {
  final User user;
  final MusicProvider musicProvider;

  NowPlayingPage([this.user, this.musicProvider]);

  @override
  _NowPlayingPageState createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    initService();
  }

  void initService() async {
    await AudioService.connect();
    if (widget.user != null && widget.musicProvider != null) {
      await startAudioTask();
      IsolateNameServer.lookupPortByName('audio_task').send(
        <dynamic>[
          widget.user,
          widget.musicProvider,
          csrfToken,
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DynamicAppBar('Now Playing'),
      drawer: const NavigationDrawerWidget('/now_playing'),
      body: StreamBuilder<List<MediaItem>>(
        initialData: AudioService.queue,
        stream: AudioService.queueStream,
        builder: (context, snapshot) {
          return Column(
            children: <Widget>[
              Expanded(
                child: ListView.builder(
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
