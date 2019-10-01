import 'package:epimetheus/pages/collection/albums_tab.dart';
import 'package:epimetheus/pages/collection/artists_tab.dart';
import 'package:epimetheus/pages/collection/playlists_tab.dart';
import 'package:epimetheus/pages/collection/stations_tab.dart';
import 'package:epimetheus/pages/collection/tracks_tab.dart';
import 'package:epimetheus/pages/navigation_drawer.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class CollectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        drawer: const NavigationDrawer(
          currentRouteName: '/collection',
        ),
        appBar: AppBar(
          title: const Text('My Collection'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: const <Widget>[
              const Tab(text: 'Stations', icon: const Icon(OMIcons.radio)),
              const Tab(text: 'Playlists', icon: const Icon(OMIcons.playlistPlay)),
              const Tab(text: 'Artists', icon: const Icon(OMIcons.person)),
              const Tab(text: 'Albums', icon: const Icon(OMIcons.album)),
              const Tab(text: 'Songs', icon: const Icon(OMIcons.audiotrack)),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            StationsTab(),
            PlaylistsTab(),
            ArtistsTab(),
            AlbumsTab(),
            TracksTab(),
          ],
        ),
      ),
    );
  }
}
