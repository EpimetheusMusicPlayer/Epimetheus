import 'package:epimetheus/audio/launch_helpers.dart';
import 'package:epimetheus/audio/providers/playlist_track_list_collection_provider.dart';
import 'package:epimetheus/libepimetheus/playlists.dart';
import 'package:epimetheus/libepimetheus/tracks.dart';
import 'package:epimetheus/models/collection/paged_collection_provider.dart';
import 'package:epimetheus/models/user/user.dart';
import 'package:epimetheus/pages/collection/paged_collection_tab.dart';
import 'package:epimetheus/widgets/collection/paged_collection_list_view.dart';
import 'package:epimetheus/widgets/playable/track.dart';
import 'package:fast_marquee/fast_marquee.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class PlaylistTracksPage extends StatefulWidget {
  final String pandoraId;

  const PlaylistTracksPage({
    @required this.pandoraId,
  });

  static const pathPrefix = 'playlist';

  static Route<dynamic> generateRoute(RouteSettings settings, List<String> paths) {
    if (paths[1].startsWith('PL:'))
      return generateLocalRoute(settings, paths);
    else
      return null;
  }

  static Route<void> generateLocalRoute(RouteSettings settings, List<String> paths) {
    return MaterialPageRoute(
      builder: (context) {
        return PlaylistTracksPage(pandoraId: paths.last);
      },
      settings: settings,
    );
  }

  @override
  _PlaylistTracksPageState createState() => _PlaylistTracksPageState();
}

class _PlaylistTracksPageState extends State<PlaylistTracksPage> {
  PlaylistTrackListCollectionProvider _collectionProvider;
  PlaylistTrackList _initialData;

  @override
  void initState() {
    super.initState();
    _collectionProvider = PlaylistTrackListCollectionProvider(DefaultCacheManager(), widget.pandoraId);
  }

  Future<PlaylistTrackList> _getInitialData() async {
    final model = UserModel.of(context);
    // if (!model.ensureHasUser(context)) return null;
    if (_initialData == null) _initialData = await _collectionProvider.getInitialData(model.user);
    return _initialData;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PlaylistTrackList>(
      future: _getInitialData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: _PlaylistTracksAppBar(snapshot.data.pandoraId, snapshot.data.name, snapshot.data.description),
            body: _PlaylistTracksPageList(_collectionProvider),
          );
        } else {
          final List<String> arguments = ModalRoute.of(context).settings.arguments;
          return Scaffold(
            appBar: _PlaylistTracksAppBar(widget.pandoraId, arguments[0], arguments[1]),
            body: snapshot.hasError
                ? PagedCollectionListViewErrorDisplay(
                    typeName: 'playlist tracks',
                    onRefresh: () {
                      print((snapshot.error as TypeError).stackTrace);
                      Navigator.of(context).pushReplacementNamed('/playlist/${widget.pandoraId}', arguments: arguments);
                    },
                  )
                : Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}

class _PlaylistTracksAppBar extends StatelessWidget implements PreferredSizeWidget {
  static const size = kToolbarHeight + 8;

  final String pandoraId;
  final String name;
  final String description;

  const _PlaylistTracksAppBar(this.pandoraId, this.name, this.description);

  @override
  Size get preferredSize => const Size.fromHeight(size);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: size,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name ?? 'Playlist'),
          SizedBox(height: 4),
          Marquee(
            text: description ?? '...',
            style: TextStyle(
              color: Colors.white,
            ),
            velocity: 50,
            blankSpace: 30,
            pauseAfterRound: const Duration(seconds: 2),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(OMIcons.playArrow),
          tooltip: 'Play',
          onPressed: () {
            launchMusicProviderFromId<Playlist>(context, pandoraId);
          },
        ),
      ],
    );
  }
}

class _PlaylistTracksPageList extends PagedCollectionTab<Track> {
  final PlaylistTrackListCollectionProvider _collectionProvider;

  _PlaylistTracksPageList(this._collectionProvider);

  @override
  PagedCollectionProvider<Track> getCollectionProvider(BuildContext context) => _collectionProvider;

  @override
  Widget itemListTileBuilder(context, track, index, storePosition, showMenu, launch) {
    return InkWell(
      onTapDown: storePosition,
      child: TrackListTile(track),
    );
  }
}
