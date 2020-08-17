import 'package:epimetheus/pages/collection/albums_tab.dart';
import 'package:epimetheus/pages/collection/artists_tab.dart';
import 'package:epimetheus/pages/collection/playlists_tab.dart';
import 'package:epimetheus/pages/collection/stations_tab.dart';
import 'package:epimetheus/pages/collection/tracks_tab.dart';
import 'package:epimetheus/pages/navigation_drawer.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class CollectionPage extends StatefulWidget {
  @override
  _CollectionPageState createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> with SingleTickerProviderStateMixin {
  TabController _tabController;
  CollectionPageFAB _fabData;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 5,
      vsync: this,
    )..addListener(() {
        setState(() {
          _fabData = CollectionPageFAB._fabs[_tabController.index];
        });
      });

    _fabData = CollectionPageFAB._fabs[_tabController.index];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fab = _fabData == null
        ? null
        : FloatingActionButton(
            isExtended: _fabData.expanded,
            tooltip: _fabData.tooltip,
            child: Icon(_fabData.icon),
            onPressed: () {
              _fabData.onPressed(context);
            },
          );

    return Scaffold(
      drawer: const NavigationDrawer(
        currentRouteName: '/collection',
      ),
      appBar: AppBar(
        title: const Text('My Collection'),
        bottom: TabBar(
          controller: _tabController,
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
      floatingActionButton: fab,
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          StationsTab(),
          PlaylistsTab(),
          ArtistsTab(),
          AlbumsTab(),
          TracksTab(),
        ],
      ),
    );
  }
}

// TODO this FAB architecture is terrible, re-implement in a cleaner way
class CollectionPageFAB {
  final bool expanded;
  final String title;
  final String tooltip;
  final IconData icon;
  final Function(BuildContext context) onPressed;

  CollectionPageFAB({
    @required this.expanded,
    @required this.title,
    @required this.tooltip,
    @required this.icon,
    @required this.onPressed,
  });

  static List<CollectionPageFAB> _fabs = [
    StationsTab.fab,
    null,
    null,
    null,
    null,
  ];
}
