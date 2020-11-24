import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/features/collection/ui/tabs/categories/album.dart';
import 'package:epimetheus/features/collection/ui/tabs/categories/artist.dart';
import 'package:epimetheus/features/collection/ui/tabs/categories/playlist.dart';
import 'package:epimetheus/features/collection/ui/tabs/categories/song.dart';
import 'package:epimetheus/features/collection/ui/tabs/station.dart';
import 'package:epimetheus/features/navigation/ui/widgets/navigation_drawer.dart';
import 'package:epimetheus/features/playback/entities/audio_task_keys.dart';
import 'package:epimetheus/features/playback/ui/widgets/media_control_container.dart';
import 'package:epimetheus/logging.dart';
import 'package:epimetheus/routes.dart';
import 'package:epimetheus_nullable/mobx/collection/collection_store.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CollectionPage extends StatefulWidget {
  @override
  _CollectionPageState createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  final collectionStore = GetIt.instance<CollectionStore>();

  String? _playingId = AudioService
      .currentMediaItem?.extras[AudioTaskMetadataKeys.mediaSourceId];
  late final _playingIdStream = AudioService.currentMediaItemStream.transform(
    StreamTransformer<MediaItem?, String?>.fromHandlers(
      handleData: (mediaItem, sink) {
        final newId = mediaItem?.extras[AudioTaskMetadataKeys.mediaSourceId];
        if (_playingId != newId) {
          _playingId = newId;
          sink.add(newId);
        }
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      initialIndex: 0,
      child: Scaffold(
        drawer: NavigationDrawer(currentRouteName: RouteNames.collection),
        appBar: AppBar(
          title: const Text('My Collection'),
          bottom: TabBar(
            tabs: const [
              Tab(
                text: 'Stations',
                icon: Icon(Icons.radio_outlined),
              ),
              Tab(
                text: 'Playlists',
                icon: Icon(Icons.playlist_play_outlined),
              ),
              Tab(
                text: 'Artists',
                icon: Icon(Icons.person_outline_outlined),
              ),
              Tab(
                text: 'Albums',
                icon: Icon(Icons.album_outlined),
              ),
              Tab(
                text: 'Songs',
                icon: Icon(Icons.audiotrack_outlined),
              ),
            ],
          ),
          actions: kDebugMode ? [buildLogScreenAction(context)] : null,
        ),
        body: MediaControlContainer(
          child: StreamBuilder<String?>(
            stream: _playingIdStream,
            initialData: _playingId,
            builder: (context, snapshot) {
              return TabBarView(
                children: [
                  StationTab(
                    collectionStore: collectionStore,
                    playingId: snapshot.data,
                  ),
                  PlaylistCategoryTab(
                    collectionStore: collectionStore,
                    playingId: snapshot.data,
                  ),
                  ArtistCategoryTab(
                    collectionStore: collectionStore,
                    playingId: snapshot.data,
                  ),
                  AlbumCategoryTab(
                    collectionStore: collectionStore,
                    playingId: snapshot.data,
                  ),
                  SongCategoryTab(
                    collectionStore: collectionStore,
                    playingId: snapshot.data,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
