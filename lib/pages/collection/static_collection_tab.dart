import 'package:epimetheus/libepimetheus/structures/pandora_entity.dart';
import 'package:epimetheus/models/collection/collection_model.dart';
import 'package:epimetheus/models/collection/static_collection_provider.dart';
import 'package:epimetheus/models/user/user.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

abstract class StaticCollectionTab<T extends PandoraEntity> extends StatelessWidget {
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  Widget buildMainContent(BuildContext context, List<T> data);

  @override
  Widget build(BuildContext context) {
    final user = UserModel.of(context).user;
    final collectionProvider = CollectionModel.of(context).getCollectionProvider(T) as StaticCollectionProvider;

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
                    'There was an error showing your ${collectionProvider.typeName}.',
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

          if (!collectionProvider.getAsync(user)) {
            return const Center(
              child: const CircularProgressIndicator(),
            );
          }

          return buildMainContent(context, collectionProvider.getDownloaded());
        },
      ),
    );
  }
}
