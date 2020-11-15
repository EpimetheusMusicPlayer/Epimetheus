import 'package:epimetheus/core/ui/error.dart';
import 'package:epimetheus/features/auth/entities/auth_entities.dart';
import 'package:epimetheus/routes.dart';
import 'package:epimetheus_nullable/mobx/auth/auth_store.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:iapetus/iapetus.dart';
import 'package:mobx/mobx.dart';

/// Watches for authentication errors,
ReactionDisposer watchAuthErrors(
  void Function(Object error) handleUIError,
) {
  final authStore = GetIt.instance<AuthStore>();
  return reaction<AuthStatus>(
    (_) => authStore.authStatus,
    (authStatus) {
      if (authStatus == AuthStatus.error) {
        handleUIError(authStore.error);
      }
    },
  );
}

// TODO add retry, and also supply credentials back to login screen
/// Handles authentication errors. Returns true if the error is dealt with.
bool handleAuthErrors({
  required BuildContext context,
  required Object error,
  required UIErrorMessageCallback showErrorMessage,
  required void Function(String routeName) navigateTo,
}) {
  if (error is InvalidAuthException) {
    showErrorMessage(
      context: context,
      errorTitle: 'Incorrect email or password.',
      errorMessage: 'Please try again, or reset your password at pandora.com.',
      actionLabels: const ['Back'],
      actions: [
        ({required closeErrorWindow}) {
          closeErrorWindow();
          navigateTo(RouteNames.login);
        },
      ],
    );
    return true;
  } else if (error is IapetusNetworkException) {
    showErrorMessage(
      context: context,
      errorTitle: 'Can\'t connect to Pandora.',
      errorMessage: 'Are you connected to the Internet?',
      actionLabels: const ['Back'],
      actions: [
        ({required closeErrorWindow}) {
          closeErrorWindow();
          navigateTo(RouteNames.login);
        },
      ],
    );
    return true;
  } else if (error is LocationException) {
    showErrorMessage(
      context: context,
      errorTitle: 'You\'re outside the USA.',
      errorMessage: 'Use a VPN or proxy, or book a flight to use the app.',
      actionLabels: const ['Back'],
      actions: [
        ({required closeErrorWindow}) {
          closeErrorWindow();
          navigateTo(RouteNames.login);
        },
      ],
    );
    return true;
  } else if (error is UnknownPandoraErrorException) {
    showErrorMessage(
      context: context,
      errorTitle: 'An unknown API error occurred.',
      errorMessage: error.toString(),
      actionLabels: const ['Back'],
      actions: [
        ({required closeErrorWindow}) {
          closeErrorWindow();
          navigateTo(RouteNames.login);
        },
      ],
    );
    return true;
  }

  return false;
}
