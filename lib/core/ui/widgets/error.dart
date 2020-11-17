import 'package:flutter/material.dart';

/// An error widget (like a dialog or snackbar) can be given a list of these,
/// which it will use as optional actions that the user can tap on.
typedef UIErrorAction = void Function({
  required void Function() closeErrorWindow,
});

/// Shows an error dialog.
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
