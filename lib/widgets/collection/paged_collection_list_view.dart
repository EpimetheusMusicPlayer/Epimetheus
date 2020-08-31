import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:epimetheus/libepimetheus/collections.dart';
import 'package:epimetheus/libepimetheus/structures/paged_collection_list.dart';
import 'package:epimetheus/libepimetheus/structures/pandora_entity.dart';
import 'package:epimetheus/widgets/mixins/custom_context_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pagination_wrapper/flutter_pagination_wrapper.dart';

typedef DataClearCallback = Future<void> Function();
typedef ErrorCheckCallback = bool Function();

class PagedCollectionListView<T extends PandoraEntity> extends StatefulWidget {
  final String typeName;
  final PageLoadFuture<PagedCollectionList<T>> pageLoadFuture;
  final DataClearCallback dataClearCallback;
  final ErrorCheckCallback checkForError;
  final ItemListTileBuilder<T> itemListTileBuilder;
  final IndexedWidgetBuilder separatorBuilder;
  final PagedCollectionList<T> initialPage;
  final int initialPageNumber;

  PagedCollectionListView({
    Key key,
    @required this.typeName,
    @required this.pageLoadFuture,
    this.dataClearCallback,
    this.checkForError,
    @required this.itemListTileBuilder,
    this.separatorBuilder,
    this.initialPage,
    this.initialPageNumber = 1,
  }) : super(key: key);

  @override
  PagedCollectionListViewState<T> createState() => PagedCollectionListViewState<T>();
}

class PagedCollectionListViewState<T extends PandoraEntity> extends State<PagedCollectionListView<T>> with AutomaticKeepAliveClientMixin<PagedCollectionListView<T>> {
  final _refreshKey = GlobalKey<RefreshIndicatorState>();
  final _paginationKey = GlobalKey<PaginatorState<PagedCollectionList<T>, T>>();

  bool _collectionChanged = false;

  @override
  bool get wantKeepAlive => true;

  Future<void> refresh() => _refreshKey.currentState.show();

  Future<void> _refresh() async {
    await widget.dataClearCallback?.call();
    _collectionChanged = false;
    _paginationKey.currentState.refresh();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Widget errorListTileBuilder(BuildContext context, PagedCollectionList<T> page, int existingItemCount) {
      return PagedCollectionListViewErrorDisplay(
        typeName: widget.typeName,
        collectionChanged: _collectionChanged,
        onRefresh: refresh,
      );
    }

    Widget emptyListWidgetBuilder(BuildContext context, PagedCollectionList<T> page) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Align(
          alignment: Alignment(0, -0.2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.note,
                color: Colors.black26,
                size: 256,
              ),
              const SizedBox(height: 32),
              Text(
                'You have no ${widget.typeName}. Go to Explore to find some!',
                textScaleFactor: 1.4,
              ),
              FlatButton(
                onPressed: refresh,
                child: Text(
                  'Refresh',
                  textScaleFactor: 1.2,
                ),
              ),
            ],
          ),
        ),
      );
    }

    Future<PagedCollectionList<T>> _pageLoadFuture(int pageNumber) async {
      try {
        return await widget.pageLoadFuture(pageNumber);
      } on PagedCollectionListException catch (e) {
        if (e.reason == PagedCollectionListExceptionReason.totalCountMismatch) {
          _collectionChanged = true;
        }
        return null;
      }
    }

    List<T> pageItemsGetter(PagedCollectionList<T> page) => page.items;

    Widget loadingListTileBuilder(BuildContext context) => const Align(
          alignment: Alignment.center,
          child: const Padding(
            padding: const EdgeInsets.all(16),
            child: const SizedBox(
              width: 24,
              height: 24,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          ),
        );

    int totalItemsGetter(PagedCollectionList<T> page) => page?.totalCount ?? 0;

    bool pageErrorChecker(PagedCollectionList<T> page) => page == null || (widget.checkForError?.call() ?? false);

    return RefreshIndicator(
      key: _refreshKey,
      onRefresh: _refresh,
      child: Paginator<PagedCollectionList<T>, T>(
        key: _paginationKey,
        pageLoadFuture: _pageLoadFuture,
        pageErrorChecker: pageErrorChecker,
        totalItemsGetter: totalItemsGetter,
        pageItemsGetter: pageItemsGetter,
        itemListTileBuilder: widget.itemListTileBuilder,
        loadingListTileBuilder: loadingListTileBuilder,
        errorListTileBuilder: errorListTileBuilder,
        emptyListWidgetBuilder: emptyListWidgetBuilder,
        listBuilder: (context, itemBuilder, itemCount) {
          return widget.separatorBuilder == null
              ? ListView.builder(
                  itemBuilder: itemBuilder,
                  itemCount: itemCount,
                )
              : ListView.separated(
                  itemBuilder: itemBuilder,
                  itemCount: itemCount,
                  separatorBuilder: widget.separatorBuilder,
                );
        },
        initialPage: widget.initialPage,
        initialPageNumber: widget.initialPageNumber,
      ),
    );
  }
}

class PagedCollectionListViewErrorDisplay extends StatelessWidget {
  final String typeName;
  final bool collectionChanged;
  final VoidCallback onRefresh;

  const PagedCollectionListViewErrorDisplay({
    @required this.typeName,
    this.collectionChanged = false,
    @required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(0, -0.2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            collectionChanged ? Icons.refresh : Icons.network_check,
            color: Colors.black54,
            size: 256,
          ),
          const SizedBox(height: 32),
          Text(
            collectionChanged ? 'Your ${typeName} list changed.' : 'There was an error fetching your ${typeName}.',
            textScaleFactor: 1.4,
          ),
          const SizedBox(height: 12),
          FlatButton(
            onPressed: onRefresh,
            child: Text(
              collectionChanged ? 'Refresh' : 'Retry',
              textScaleFactor: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

enum StandardPopupMenuItem { delete, add }

typedef AddRemoveCallback = void Function(Future<bool> future);

mixin StandardPopupMenu<T extends StatefulWidget, TpandoraEntity extends PandoraEntity> on CustomPopupMenu<T> {
  Future<Treturn> showStandardMenu<Treturn>(
    BuildContext context,
    User user,
    TpandoraEntity collectionItem, {
    Map<StandardPopupMenuItem, String> standardMenuItems = const {
      StandardPopupMenuItem.delete: 'Remove',
    },
    List<PopupMenuItem<Treturn>> customMenuItems = const [],
    AddRemoveCallback onAddRemove,
    VoidCallback refresh,
  }) async {
    if (standardMenuItems.isEmpty && customMenuItems.isEmpty) return null;
    final selection = await this.showMenu<dynamic>(
      context: context,
      items: [
        ...customMenuItems,
        if (standardMenuItems.containsKey(StandardPopupMenuItem.delete))
          PopupMenuItem<dynamic>(
            value: StandardPopupMenuItem.delete,
            child: Row(
              children: [
                const Icon(Icons.remove_circle_outline),
                const SizedBox(width: 16),
                Text(standardMenuItems[StandardPopupMenuItem.delete]),
              ],
            ),
          ),
        if (standardMenuItems.containsKey(StandardPopupMenuItem.add))
          PopupMenuItem<dynamic>(
            value: StandardPopupMenuItem.add,
            child: Row(
              children: [
                const Icon(Icons.add_circle_outline),
                const SizedBox(width: 16),
                Text(standardMenuItems[StandardPopupMenuItem.add]),
              ],
            ),
          ),
      ],
    );

    if (selection is StandardPopupMenuItem) {
      switch (selection) {
        case StandardPopupMenuItem.delete:
          final removeFuture = collectionItem.remove(user);
          onAddRemove?.call(removeFuture);
          refresh();
          break;
        case StandardPopupMenuItem.add:
          final addFuture = collectionItem.add(user);
          onAddRemove?.call(addFuture);
          refresh();
          break;
      }
      return null;
    } else {
      return selection;
    }
  }
}
