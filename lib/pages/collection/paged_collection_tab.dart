import 'package:epimetheus/audio/launch_helpers.dart';
import 'package:epimetheus/libepimetheus/structures/collection/paged_collection_list.dart';
import 'package:epimetheus/libepimetheus/structures/pandora_entity.dart';
import 'package:epimetheus/models/collection/collection_model.dart';
import 'package:epimetheus/models/collection/paged_collection_provider.dart';
import 'package:epimetheus/models/user/user.dart';
import 'package:epimetheus/widgets/collection/paged_collection_list_view.dart';
import 'package:epimetheus/widgets/mixins/custom_context_menu.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

typedef PositionStorer = void Function(TapDownDetails details);
typedef MenuShower = Future<T> Function<T>({Map<StandardPopupMenuItem, String> standardMenuItems, List<PopupMenuItem<T>> customMenuItems});
typedef ItemListTileBuilderWithMenu<T extends PandoraEntity> = Widget Function(BuildContext context, T item, int index, PositionStorer storePosition, MenuShower showMenu, VoidCallback launch);

abstract class PagedCollectionTab<T extends PandoraEntity> extends StatelessWidget {
  final bool buildSeparators;

  const PagedCollectionTab({this.buildSeparators = false});

  Widget itemListTileBuilder(BuildContext context, T item, int index, PositionStorer storePosition, MenuShower showMenu, VoidCallback launch);

  Widget separatorBuilder(BuildContext context, int index) => throw Error();

  PagedCollectionProvider<T> getCollectionProvider(BuildContext context) => CollectionModel.of(context).getCollectionProvider<T>();

  @override
  Widget build(BuildContext context) {
    return _PagedCollectionTabListView(
      itemListTileBuilder: itemListTileBuilder,
      separatorBuilder: buildSeparators ? separatorBuilder : null,
      collectionProvider: getCollectionProvider(context),
    );
  }
}

class _PagedCollectionTabListView<T extends PandoraEntity> extends StatefulWidget {
  final ItemListTileBuilderWithMenu<T> itemListTileBuilder;
  final IndexedWidgetBuilder separatorBuilder;
  final PagedCollectionProvider<T> collectionProvider;

  _PagedCollectionTabListView({
    @required this.itemListTileBuilder,
    this.separatorBuilder,
    this.collectionProvider,
  });

  @override
  _PagedCollectionTabListViewState<T> createState() => _PagedCollectionTabListViewState<T>();
}

class _PagedCollectionTabListViewState<T extends PandoraEntity> extends State<_PagedCollectionTabListView<T>> with CustomPopupMenu<_PagedCollectionTabListView<T>>, StandardPopupMenu<_PagedCollectionTabListView<T>, T> {
  final _listKey = GlobalKey<PagedCollectionListViewState>();

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<CollectionModel>(
      rebuildOnChange: false,
      builder: (context, _, collectionModel) {
        return ScopedModelDescendant<UserModel>(
          rebuildOnChange: false,
          builder: (context, _, userModel) {
            final collectionProvider = widget.collectionProvider;
            final user = userModel.user;

            Widget _itemListTileBuilder(BuildContext context, T item, int index) {
              Future<S> showMenu<S>({
                Map<StandardPopupMenuItem, String> standardMenuItems = const {
                  StandardPopupMenuItem.delete: 'Remove',
                },
                List<PopupMenuItem<S>> customMenuItems = const [],
              }) {
                return showStandardMenu<S>(
                  context,
                  user,
                  item,
                  standardMenuItems: standardMenuItems,
                  customMenuItems: customMenuItems,
                  onAddRemove: (future) => collectionProvider.addPendingFuture(future),
                  refresh: () => _listKey.currentState.refresh(),
                );
              }

              void launch() {
                launchMusicProviderFromCollection<T>(context, index);
              }

              return widget.itemListTileBuilder(context, item, index, storePosition, showMenu, launch);
            }

            return PagedCollectionListView<T>(
              key: _listKey,
              typeName: collectionProvider.typeName,
              pageLoadFuture: (pageNumber) => collectionProvider.newPage(user, PagedCollectionList.pageNumberToIndex(pageNumber, collectionProvider.pageSize)),
              dataClearCallback: () => collectionProvider.reset(user),
              checkForError: () => collectionProvider.hasError,
              itemListTileBuilder: _itemListTileBuilder,
              separatorBuilder: widget.separatorBuilder,
              initialPage: collectionProvider.collection,
              initialPageNumber: ((collectionProvider.collection?.items?.length ?? 0) / collectionProvider.pageSize).ceil(),
            );
          },
        );
      },
    );
  }
}
