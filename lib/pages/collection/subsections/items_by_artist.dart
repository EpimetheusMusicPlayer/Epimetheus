import 'package:epimetheus/libepimetheus/albums.dart';
import 'package:epimetheus/libepimetheus/artists.dart';
import 'package:epimetheus/libepimetheus/structures/pandora_entity.dart';
import 'package:epimetheus/models/collection/collection_model.dart';
import 'package:epimetheus/models/collection/paged_collection_provider.dart';
import 'package:epimetheus/models/collection/standard_paged_collection_provider.dart';
import 'package:epimetheus/models/user/user.dart';
import 'package:epimetheus/pages/collection/paged_collection_tab.dart';
import 'package:epimetheus/widgets/collection/paged_collection_list_view.dart';
import 'package:epimetheus/widgets/mixins/custom_context_menu.dart';
import 'package:epimetheus/widgets/playable/dynamic.dart';
import 'package:flutter/material.dart';

class CollectedItemsByArtistPage extends StatefulWidget {
  final String pandoraId;

  const CollectedItemsByArtistPage({
    @required this.pandoraId,
  });

  static Route<void> generateLocalRoute(RouteSettings settings, List<String> paths) {
    return MaterialPageRoute(
      builder: (context) {
        return CollectedItemsByArtistPage(pandoraId: paths.last);
      },
      settings: settings,
    );
  }

  @override
  _CollectedItemsByArtistPageState createState() => _CollectedItemsByArtistPageState();
}

class _CollectedItemsByArtistPageState extends State<CollectedItemsByArtistPage> with CustomPopupMenu, StandardPopupMenu {
  StandardPagedCollectionProvider<PandoraEntity> _collectionProvider;
  Artist _initialData;

  @override
  void initState() {
    super.initState();
    _collectionProvider = StandardPagedCollectionProvider(
      pageGetter: ({limit, offset, sortOrder, user}) {
        return Artist.getCollectedItemsFromId(
          pandoraId: widget.pandoraId,
          user: user,
          limit: CollectionModel.pageSize,
          offset: offset,
        );
      },
      typeName: 'artist\'s items',
    );
  }

  Future<Artist> _getInitialData() async {
    if (_initialData == null) {
      _initialData = (await _collectionProvider.newPage(UserModel.of(context).user, 0)).relatedItems.singleWhere(
            (item) => item.pandoraId == widget.pandoraId,
            orElse: () => null,
          );
    }

    return _initialData;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Artist>(
      future: _getInitialData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Collected items by ${snapshot.data?.name ?? 'artist'}'),
            ),
            body: _CollectedItemsByArtistPageList(_collectionProvider),
          );
        } else {
          final String artistName = ModalRoute.of(context).settings.arguments;
          return Scaffold(
            appBar: AppBar(
              title: Text('Collected items ${artistName == null ? '' : 'by $artistName'}'),
            ),
            body: snapshot.hasError
                ? PagedCollectionListViewErrorDisplay(
                    typeName: 'artist\'s items',
                    onRefresh: () {
                      Navigator.of(context).pushReplacementNamed('/collection/artists/${widget.pandoraId}', arguments: artistName);
                    },
                  )
                : Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}

class _CollectedItemsByArtistPageList extends PagedCollectionTab<PandoraEntity> {
  final StandardPagedCollectionProvider _collectionProvider;

  const _CollectedItemsByArtistPageList(this._collectionProvider);

  @override
  PagedCollectionProvider<PandoraEntity> getCollectionProvider(BuildContext context) => _collectionProvider;

  @override
  Widget itemListTileBuilder(BuildContext context, PandoraEntity item, int index, storePosition, Future<T> Function<T>({List<PopupMenuItem<T>> customMenuItems, Map<StandardPopupMenuItem, String> standardMenuItems}) showMenu, launch) {
    return InkWell(
      onTapDown: storePosition,
      onLongPress: () {
        if (item is Album) {
          showMenu<void>(
            standardMenuItems: {
              if (item.trackCount == item.collectedTrackCount) StandardPopupMenuItem.delete: 'Remove' else StandardPopupMenuItem.add: 'Add all tracks',
            },
          );
        } else {
          showMenu<void>();
        }
      },
      child: DynamicPlayableListTile(item),
    );
  }
}
