import 'dart:io';

import 'package:epimetheus/libepimetheus/albums.dart';
import 'package:epimetheus/libepimetheus/artists.dart';
import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:epimetheus/libepimetheus/exceptions.dart';
import 'package:epimetheus/libepimetheus/structures/paged_collection_list.dart';
import 'package:epimetheus/libepimetheus/structures/pandora_entity.dart';
import 'package:epimetheus/models/collection/collection_model.dart';
import 'package:epimetheus/models/user/user.dart';
import 'package:epimetheus/widgets/collection/paged_collection_list_view.dart';
import 'package:epimetheus/widgets/mixins/custom_context_menu.dart';
import 'package:epimetheus/widgets/playable/dynamic.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class CollectedItemsByArtistPage extends StatefulWidget {
  final String pandoraId;

  const CollectedItemsByArtistPage({
    @required this.pandoraId,
  });

  static Route<void> generateRoute(RouteSettings settings, List<String> paths) {
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
  final _listKey = GlobalKey<PagedCollectionListViewState>();
  final _pendingFutures = <Future<dynamic>>[];

  Future<PagedCollectionList<PandoraEntity>> _getPage(User user, int offset) async {
    await Future.wait(_pendingFutures);
    return await Artist.getCollectedItemsFromId(
      pandoraId: widget.pandoraId,
      user: user,
      limit: CollectionModel.pageSize,
      offset: offset,
    );
  }

  _itemListTileBuilder(BuildContext context, PandoraEntity item, int index, User user) {
    return InkWell(
      onTapDown: storePosition,
      onLongPress: () {
        if (item is Album) {
          showStandardMenu(
            context,
            user,
            item,
            refresh: _listKey.currentState.refresh,
            onAddRemove: (future) => _pendingFutures.add(future..then((future) => _pendingFutures.remove(future))),
            standardMenuItems: {
              if (item.trackCount == item.collectedTrackCount) StandardPopupMenuItem.delete: 'Remove' else StandardPopupMenuItem.add: 'Add all tracks',
            },
          );
        } else {
          showStandardMenu(
            context,
            user,
            item,
            refresh: _listKey.currentState.refresh,
            onAddRemove: (future) => _pendingFutures.add(future..then((future) => _pendingFutures.remove(future))),
          );
        }
      },
      child: DynamicPlayableListTile(item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PagedCollectionList<PandoraEntity>>(
      future: _getPage(UserModel.of(context).user, 0),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final Artist artist = snapshot.data.relatedItems.singleWhere((item) => item.pandoraId == widget.pandoraId, orElse: () => null);

          return Scaffold(
            appBar: AppBar(
              title: Text('Collected items by ${artist?.name ?? 'artist'}'),
            ),
            body: ScopedModelDescendant<UserModel>(
              builder: (context, _, model) {
                return PagedCollectionListView<PandoraEntity>(
                  key: _listKey,
                  typeName: 'artist\'s items',
                  pageLoadFuture: (pageNumber) async {
                    try {
                      return await _getPage(
                        model.user,
                        PagedCollectionList.pageNumberToIndex(pageNumber, CollectionModel.pageSize),
                      );
                    } on SocketException {
                      return null;
                    } on PandoraException {
                      return null;
                    }
                  },
                  itemListTileBuilder: (BuildContext context, PandoraEntity item, int index) => _itemListTileBuilder(context, item, index, model.user),
                  initialPage: snapshot.data,
                  initialPageNumber: 1,
                );
              },
            ),
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
