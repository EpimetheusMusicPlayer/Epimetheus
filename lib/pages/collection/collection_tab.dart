import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:epimetheus/models/collection.dart';
import 'package:epimetheus/models/user.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

abstract class CollectionTab<T> extends StatelessWidget {
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  final String errorMessage;

  CollectionTab({
    @required this.errorMessage,
  });

  Future<void> refresh(User user, CollectionModel model);
  T get(User user, CollectionModel model);

  bool hasError(CollectionModel model);

  Widget buildMainContent(BuildContext context, T data);

  @override
  Widget build(BuildContext context) {
    final user = UserModel.of(context).user;

    return RefreshIndicator(
      key: _refreshKey,
      onRefresh: () => refresh(user, CollectionModel.of(context)),
      child: ScopedModelDescendant<CollectionModel>(
        builder: (context, child, model) {
          if (hasError(model)) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    errorMessage,
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

          final data = get(user, model);

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
