import 'package:epimetheus/features/auth/entities/auth_entities.dart';
import 'package:epimetheus/routes.dart';
import 'package:epimetheus_nullable/mobx/auth/auth_store.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';

List<ReactionDisposer> setupNavigationReactions(
  void Function(String routeName) navigateBackTo,
) {
  final authStore = GetIt.instance<AuthStore>();
  return [
    autorun((_) {
      _handleAuthNavigation(authStore.authStatus, navigateBackTo);
      _handleListenerPrecaching(authStore);
    }),
  ];
}

/// Navigates based on the authentication status.
void _handleAuthNavigation(
  AuthStatus status,
  void Function(String routeName) navigateTo,
) {
  switch (status) {
    case AuthStatus.loggingIn:
      navigateTo(RouteNames.authenticating);
      return;
    case AuthStatus.loggedIn:
      navigateTo(RouteNames.collection);
      return;
    case AuthStatus.loggedOut:
      navigateTo(RouteNames.login);
      return;
    default:
      return;
  }
}

/// Pre-caches listener assets.
void _handleListenerPrecaching(AuthStore authStore) {
  if (authStore.authStatus == AuthStatus.loggedIn) {
    DefaultCacheManager().downloadFile(authStore.listener!.profileImageUrl);
  }
}
