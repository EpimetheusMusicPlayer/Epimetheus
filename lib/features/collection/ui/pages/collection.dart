import 'package:epimetheus/features/collection/ui/tabs/categories/album.dart';
import 'package:epimetheus/features/collection/ui/tabs/categories/artist.dart';
import 'package:epimetheus/features/collection/ui/tabs/categories/playlist.dart';
import 'package:epimetheus/features/collection/ui/tabs/categories/song.dart';
import 'package:epimetheus/features/collection/ui/tabs/station.dart';
import 'package:epimetheus/features/navigation/ui/widgets/navigation_drawer.dart';
import 'package:epimetheus/routes.dart';
import 'package:epimetheus_nullable/mobx/collection/collection_store.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger_flutter/logger_flutter.dart';

class CollectionPage extends StatelessWidget {
  final collectionStore = GetIt.instance<CollectionStore>();

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
              Tab(text: 'Stations', icon: Icon(Icons.radio_outlined)),
              Tab(text: 'Playlists', icon: Icon(Icons.playlist_play_outlined)),
              Tab(text: 'Artists', icon: Icon(Icons.person_outline_outlined)),
              Tab(text: 'Albums', icon: Icon(Icons.album_outlined)),
              Tab(text: 'Songs', icon: Icon(Icons.audiotrack_outlined)),
            ],
          ),
          actions: kDebugMode
              ? [
                  IconButton(
                    icon: const Icon(Icons.bug_report_outlined),
                    tooltip: 'Debug log',
                    onPressed: () => LogConsole.open(context),
                  )
                ]
              : null,
        ),
        body: TabBarView(
          children: [
            StationTab(collectionStore: collectionStore),
            PlaylistCategoryTab(collectionStore: collectionStore),
            ArtistCategoryTab(collectionStore: collectionStore),
            AlbumCategoryTab(collectionStore: collectionStore),
            SongCategoryTab(collectionStore: collectionStore),
          ],
        ),
      ),
    );
  }
}
