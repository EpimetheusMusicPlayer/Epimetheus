import 'package:epimetheus/pages/collection/albums_tab.dart';
import 'package:epimetheus/pages/collection/artists_tab.dart';
import 'package:epimetheus/pages/collection/playlists_tab.dart';
import 'package:epimetheus/pages/collection/stations_tab.dart';
import 'package:epimetheus/pages/navigation_drawer.dart';
import 'package:flutter/material.dart';

class CollectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        drawer: const NavigationDrawer(
          currentRouteName: '/collection',
        ),
        appBar: AppBar(
          title: const Text('My Collection'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: const <Widget>[
              const Tab(text: 'Stations'),
              const Tab(text: 'Playlists'),
              const Tab(text: 'Albums'),
              const Tab(text: 'Artists'),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            StationsTab(),
            PlaylistsTab(),
            AlbumsTab(),
            ArtistsTab(),
          ],
        ),
      ),
    );
  }
}
