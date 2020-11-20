import 'package:epimetheus/core/ui/utils/sharing.dart';
import 'package:epimetheus/core/ui/widgets/list_footer_message.dart';
import 'package:epimetheus/core/ui/widgets/menu_items.dart';
import 'package:epimetheus/core/ui/widgets/positional_menu_wrapper.dart';
import 'package:epimetheus/features/collection/entities/collected_item.dart';
import 'package:epimetheus/features/collection/ui/widgets/progress_indicator.dart';
import 'package:epimetheus/features/collection/ui/widgets/refresh_message.dart';
import 'package:epimetheus_nullable/mobx/collection/collection_store.dart';
import 'package:flutter/material.dart';
import 'package:iapetus/iapetus.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mobx/mobx.dart';
import 'package:pedantic/pedantic.dart';

export 'package:epimetheus/core/ui/widgets/positional_menu_wrapper.dart'
    show PositionalMenuWrapperExtensions;

typedef ShowCategoryItemMenu = Future<T?> Function<T>({
  required Annotation annotation,
  required BuildContext context,
  required List<PopupMenuEntry<T>> items,
  T? initialValue,
  double? elevation,
  String? semanticLabel,
  ShapeBorder? shape,
  Color? color,
  bool useRootNavigator,
});

typedef CategoryTabCollectionModifier = Future<String?> Function(
    Future<void> Function(Iapetus api) modify);

typedef CategoryTabListTileBuilder<I extends CollectionItem,
        A extends Annotation>
    = Widget Function({
  required BuildContext context,
  required int index,
  required I item,
  required A annotation,
  required ValueChanged<Offset>? tapDownCallback,
  required ShowCategoryItemMenu? showMenu,
  required CategoryTabCollectionModifier modifyCollection,
});

class CategoryTab<I extends CollectionItem, A extends Annotation>
    extends StatefulWidget {
  final CollectionStore _collectionStore;
  final CategoryTabListTileBuilder<I, A> listTileBuilder;
  final IndexedWidgetBuilder separatorBuilder;
  final bool willUseContextMenu;

  const CategoryTab({
    required CollectionStore collectionStore,
    required this.listTileBuilder,
    required this.separatorBuilder,
    this.willUseContextMenu = true,
  }) : _collectionStore = collectionStore;

  @override
  _CategoryTabState<I, A> createState() => _CategoryTabState<I, A>(
        collectionStore: _collectionStore,
      );
}

class _CategoryTabState<I extends CollectionItem, A extends Annotation>
    extends State<CategoryTab<I, A>> with AutomaticKeepAliveClientMixin {
  final CategoryStore<I, A> _categoryStore;
  late final ReactionDisposer _pageListenerReactionDisposer;

  final _pagingController = PagingController<int, CollectedItem<I, A>>(
    firstPageKey: 0,
  );

  _CategoryTabState({
    required CollectionStore collectionStore,
  }) : _categoryStore = collectionStore.getCategoryStore<I, A>();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _pageListenerReactionDisposer = autorun((_) {
      _updatePagingState();
    });

    _pagingController.addPageRequestListener((pageKey) {
      _categoryStore.requestPageAt(pageKey);
    });
  }

  @override
  void dispose() {
    _pageListenerReactionDisposer();
    _pagingController.dispose();
    super.dispose();
  }

  void _updatePagingState() {
    _pagingController.value = PagingState(
      nextPageKey: _categoryStore.nextPageOffset,
      itemList: _categoryStore.loadedItems,
      error: _categoryStore.errorMessage,
    );
  }

  Future<void> _refresh() async {
    // Refreshing properly doesn't work at the moment; see
    // https://github.com/EdsonBueno/infinite_scroll_pagination/issues/16.
    // Clear instead, and let the paginator request a new page.
    // await _categoryStore.refresh();
    _categoryStore.clear();
    _pagingController.notifyPageRequestListeners(0);
  }

  /// This method creates a proxy [ShowMenu] that handles standard item actions.
  ShowCategoryItemMenu _makeShowMenu(ShowMenu showMenu) {
    return <T>({
      required Annotation annotation,
      required BuildContext context,
      required List<PopupMenuEntry<T>> items,
      T? initialValue,
      double? elevation,
      String? semanticLabel,
      ShapeBorder? shape,
      Color? color,
      bool useRootNavigator = false,
    }) async {
      final menuResult = await showMenu<T>(
        context: context,
        items: items,
        initialValue: initialValue,
        elevation: elevation,
        semanticLabel: semanticLabel,
        shape: shape,
        color: color,
        useRootNavigator: useRootNavigator,
      );

      if (menuResult is CommonMenuItem) {
        // Usually, refreshing should not be done by the UI after a collection
        // modification; it must be done in this case, though until the bug
        // described in _refresh() is resolved.
        switch (menuResult as CommonMenuItem) {
          case CommonMenuItem.add:
            assert(
              false,
              'Cannot add a collected item! Remove this from the menu!',
            );
            break;
          case CommonMenuItem.addSubItems:
            unawaited(
              () async {
                await _categoryStore.add(annotation);
                unawaited(_refresh());
              }(),
            );
            break;
          case CommonMenuItem.delete:
            unawaited(
              () async {
                await _categoryStore.remove(annotation);
                unawaited(_refresh());
              }(),
            );
            break;
          case CommonMenuItem.share:
            assert(
              annotation is Shareable,
              'Annotation cannot be shared!',
            );
            unawaited(shareMedia(annotation as Shareable, context));
            break;
          default:
            break;
        }
      }

      return menuResult;
    };
  }

  Future<String?> _modifyCollection(
    Future<void> Function(Iapetus api) modify,
  ) async {
    final String? errorMessage = await _categoryStore.modifyCollection(modify);
    // TODO refreshing logic should move out of the UI once the pagination bug is fixed
    if (errorMessage == null) unawaited(_refresh());
  }

  Widget _buildListView({
    ValueChanged<Offset>? tapDownCallback,
    ShowCategoryItemMenu? showMenu,
  }) {
    return PagedListView<int, CollectedItem<I, A>>.separated(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<CollectedItem<I, A>>(
        itemBuilder: (context, collectedItem, index) => widget.listTileBuilder(
          context: context,
          index: index,
          item: collectedItem.item,
          annotation: collectedItem.annotation,
          tapDownCallback: tapDownCallback,
          showMenu: showMenu,
          modifyCollection: _modifyCollection,
        ),
        firstPageErrorIndicatorBuilder: (context) {
          return TabRefreshMessage(
            message: _pagingController.error.toString(),
            onRefresh: _refresh,
          );
        },
        newPageErrorIndicatorBuilder: (context) {
          return ListFooterMessage(_pagingController.error.toString());
        },
        firstPageProgressIndicatorBuilder: (context) {
          return const TabProgressIndicator();
        },
        newPageProgressIndicatorBuilder: (context) => ListFooterMessage(
          'Loading more ${_categoryStore.typeName}s...',
        ),
        noItemsFoundIndicatorBuilder: (context) {
          return TabRefreshMessage(
            message: 'No ${_categoryStore.typeName}s.',
            onRefresh: _refresh,
          );
        },
      ),
      separatorBuilder: widget.separatorBuilder,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      onRefresh: _refresh,
      child: widget.willUseContextMenu
          ? PositionalMenuWrapper(
              builder: (context, tapDownCallback, showMenu, child) {
                return _buildListView(
                  tapDownCallback: tapDownCallback,
                  showMenu: _makeShowMenu(showMenu),
                );
              },
            )
          : _buildListView(),
    );
  }
}
