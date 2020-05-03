import 'package:epimetheus/models/collection/collection_model.dart';
import 'package:epimetheus/models/collection/collection_provider.dart';
import 'package:epimetheus/models/user/user.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

abstract class CollectionTab<T> extends StatelessWidget {
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  CollectionProvider<T> getCollectionProvider(BuildContext context);

  Widget buildMainContent(BuildContext context, List<T> data);

  @override
  Widget build(BuildContext context) {
    final user = UserModel.of(context).user;
    final collectionProvider = getCollectionProvider(context);

    return RefreshIndicator(
      key: _refreshKey,
      onRefresh: () => collectionProvider.refresh(user),
      child: ScopedModelDescendant<CollectionModel>(
        builder: (context, child, model) {
          if (collectionProvider.hasError) {
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

          final data = collectionProvider.getAsync(user);

          if (data == null) {
            return const Center(
              child: const CircularProgressIndicator(),
            );
          }

          return buildMainContent(context, data);
        },
      ),
    );
  }
}
