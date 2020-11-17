import 'package:epimetheus/features/auth/entities/auth_status.dart';
import 'package:epimetheus/features/auth/ui/errors.dart';
import 'package:epimetheus/routes.dart';
import 'package:epimetheus_nullable/mobx/auth/auth_store.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';

List<ReactionDisposer> setupNavigationReactions(
  BuildContext navigatorContext,
  void Function(String routeName, [Object? arguments]) navigateBackTo,
) {
  final authStore = GetIt.instance<AuthStore>();
  return [
    autorun((_) {
      _handleAuthNavigation(
        authStore.authState,
        navigatorContext,
        navigateBackTo,
      );
    }),
    autorun((_) {
      _handleListenerPrecaching(authStore);
    }),
  ];
}

/// Navigates based on the authentication status.
void _handleAuthNavigation(
  AuthState state,
  BuildContext navigatorContext,
  void Function(String routeName, [Object? arguments]) navigateTo,
) {
  switch (state.status) {
    case AuthStatus.loggingIn:
      navigateTo(RouteNames.authenticating);
      return;
    case AuthStatus.loggedIn:
      navigateTo(RouteNames.collection);
      return;
    case AuthStatus.loggedOut:
      navigateTo(RouteNames.login);
      return;
    case AuthStatus.error:
      navigateTo(RouteNames.login, state.creds);
      showAuthErrorDialog(navigatorContext, state.error);
      return;
    default:
      return;
  }
}

/// Pre-caches listener assets.
void _handleListenerPrecaching(AuthStore authStore) {
  if (authStore.authState.status == AuthStatus.loggedIn) {
    DefaultCacheManager().downloadFile(authStore.listener!.profileImageUrl);
  }
}
