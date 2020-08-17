import 'package:epimetheus/models/collection/paged_collection_provider.dart';
import 'package:epimetheus/models/user/user.dart';
import 'package:flutter/material.dart';
import 'package:paginator/paginator.dart';

abstract class PagedCollectionTab<T> extends StatefulWidget {
  @override
  _PagedCollectionTabState<T> createState() => _PagedCollectionTabState<T>();

  PagedCollectionProvider<T> getCollectionProvider(BuildContext context);

  Widget buildListTile(BuildContext context, int index, T item);
}

class _PagedCollectionTabState<T> extends State<PagedCollectionTab> with AutomaticKeepAliveClientMixin {
  final _refreshKey = GlobalKey<RefreshIndicatorState>();
  final _paginationKey = GlobalKey<PaginatorState>();

  bool _hasError = false;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final user = UserModel.of(context).user;
    final PagedCollectionProvider<T> collectionProvider = widget.getCollectionProvider(context);

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              collectionProvider.errorMessage,
              textAlign: TextAlign.center,
            ),
            FlatButton(
              child: const Text('Try again'),
              onPressed: _refreshKey.currentState.show,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      key: _refreshKey,
      onRefresh: () async {
        collectionProvider.clear();
        return _paginationKey.currentState.reset();
      },
      child: Paginator<T>(
        key: _paginationKey,
        initialData: collectionProvider.collection,
        pageProvider: (index) => collectionProvider.newPage(user, index),
        itemBuilder: (BuildContext context, int index, dynamic item) => widget.buildListTile(context, index, item),
        onError: (dynamic error) {
          setState(() {
            _hasError = true;
          });
          return false;
        },
      ),
    );
  }
}
