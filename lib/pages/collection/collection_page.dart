import 'package:epimetheus/pages/collection/albums_tab.dart';
import 'package:epimetheus/pages/collection/artists_tab.dart';
import 'package:epimetheus/pages/collection/playlists_tab.dart';
import 'package:epimetheus/pages/collection/stations_tab.dart';
import 'package:epimetheus/pages/collection/subsections/items_by_artist.dart';
import 'package:epimetheus/pages/collection/tracks_tab.dart';
import 'package:epimetheus/widgets/adaptive/adaptive_drawer_scaffold.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class CollectionPage extends StatefulWidget {
  static const pathPrefix = 'collection';

  static Route<dynamic> generateRoute(RouteSettings settings, List<String> paths) {
    if (paths[1] == 'artists')
      return CollectedItemsByArtistPage.generateLocalRoute(settings, paths);
    else
      return null;
  }

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

    return AdaptiveScaffold(builder: (drawer, displayMobileLayout) {
      return Scaffold(
        drawer: drawer,
        appBar: AppBar(
          automaticallyImplyLeading: displayMobileLayout,
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
//        actions: kDebugMode
//            ? [
//                IconButton(
//                  icon: const Icon(Icons.http),
//                  tooltip: 'API test',
//                  onPressed: () async {
//                    print(
//                      await makeApiRequest(
//                        version: '',
//                        endpoint: '',
//                        requestData: {},
//                        user: UserModel.of(context).user,
//                      ),
//                    );
//                  },
//                ),
//              ]
//            : null,
        ),
        floatingActionButton: fab,
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            StationsTab(),
            const PlaylistsTab(),
            const ArtistsTab(),
            const AlbumsTab(),
            const TracksTab(),
          ],
        ),
      );
    });
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
