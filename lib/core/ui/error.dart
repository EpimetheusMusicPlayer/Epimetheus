import 'package:epimetheus/core/ui/errors.dart';
import 'package:epimetheus/features/auth/ui/errors.dart';
import 'package:flutter/material.dart';

/// A UI error handler will provide a list of these, to be ran when their
/// respective action label is chosen.
typedef UIErrorAction = void Function({
  required void Function() closeErrorWindow,
});

/// UI error handlers should use this to show an error message.
typedef UIErrorMessageCallback = Future<void> Function({
  required BuildContext context,
  required String errorTitle,
  required String errorMessage,
  required List<String> actionLabels,
  required List<UIErrorAction> actions,
});

/// A UI error handler signature.
typedef UIErrorHandler = bool Function({
  required BuildContext context,
  required Object error,
  required UIErrorMessageCallback showErrorMessage,
  required void Function(String routeName) navigateTo,
});

/// A list of all UI error handlers, from most to least specialized.
const uiErrorHandlers = <UIErrorHandler>[
  handleAuthErrors,
  handleCoreErrors,
];

/// This function calls all UI error handlers, returning true after
/// any one of them resolves the error.
///
/// The error handlers are called in the most specific to least specific order;
/// the authentication flow, for example, handles network errors to show a retry
/// button, and stops the network errors reaching the standard network error
/// code.
///
/// It uses the [showErrorDialog] [UIErrorHandler] implementation.
bool handleUIError({
  required BuildContext context,
  required Object error,
  required void Function(String routeName) navigateTo,
}) {
  for (final errorHandler in uiErrorHandlers) {
    if (errorHandler(
      context: context,
      error: error,
      showErrorMessage: showErrorDialog,
      navigateTo: navigateTo,
    )) return true;
  }

  return false;
}

/// A [UIErrorMessageCallback] implementation to show a dialog.
Future<void> showErrorDialog({
  required BuildContext context,
  required String errorTitle,
  required String errorMessage,
  required List<String> actionLabels,
  required List<UIErrorAction> actions,
}) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => WillPopScope(
      onWillPop: () async => false,
      child: AlertDialog(
        title: Text(errorTitle),
        content: Text(errorMessage),
        actions: actionLabels.isEmpty
            ? null
            : [
                for (var i = actionLabels.length - 1; i >= 0; --i)
                  FlatButton(
                    textColor: Theme.of(context)!.accentColor,
                    onPressed: () => actions[i](
                      closeErrorWindow: () => Navigator.of(context)!.pop(),
                    ),
                    child: Text(actionLabels[i]),
                  ),
              ],
      ),
    ),
  );
}
