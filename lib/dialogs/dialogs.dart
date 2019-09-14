import 'package:flutter/material.dart';

/// A class defining properties common to all the various dialogs in the app.
/// Note: This class contains context and callback properties. [EpimetheusDialog] instances are designed to be used once and then thrown away.

abstract class EpimetheusDialog {
  final BuildContext context;
  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback onClickButton;

  const EpimetheusDialog({
    @required this.context,
    @required this.title,
    @required this.description,
    this.buttonLabel = 'Okay',
    @required this.onClickButton,
  });
}

void showEpimetheusDialog({
  @required EpimetheusDialog dialog,
}) {
  showDialog(
    context: dialog.context,
    barrierDismissible: false,
    builder: (context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: Text(dialog.title),
          content: Text(dialog.description),
          actions: <Widget>[
            FlatButton(
              onPressed: dialog.onClickButton,
              child: Text(dialog.buttonLabel),
            )
          ],
        ),
      );
    },
  );
}

class NetworkErrorDialog extends EpimetheusDialog {
  const NetworkErrorDialog({
    @required BuildContext context,
    String buttonLabel = 'Okay',
    @required VoidCallback onClickButton,
  }) : super(
          context: context,
          title: 'Can\'t connect to Pandora.',
          description: 'Are you connected to the Internet?',
          buttonLabel: buttonLabel,
          onClickButton: onClickButton,
        );
}

class APIErrorDialog extends EpimetheusDialog {
  const APIErrorDialog({
    @required BuildContext context,
    String buttonLabel = 'Okay',
    @required VoidCallback onClickButton,
  }) : super(
          context: context,
          title: 'An API error has occured.',
          description: 'Please sign in again. If this is a recurring issue, please contact the developer(s).',
          buttonLabel: buttonLabel,
          onClickButton: onClickButton,
        );
}

class GeoBlockErrorDialog extends EpimetheusDialog {
  const GeoBlockErrorDialog({
    @required BuildContext context,
    String buttonLabel = 'Okay',
    @required VoidCallback onClickButton,
  }) : super(
          context: context,
          title: 'You\'re outside the USA.',
          description: 'Use a VPN or proxy, or book a flight to use the app.',
          buttonLabel: buttonLabel,
          onClickButton: onClickButton,
        );
}

class AuthenticationErrorDialog extends EpimetheusDialog {
  const AuthenticationErrorDialog({
    @required BuildContext context,
    String buttonLabel = 'Okay',
    @required VoidCallback onClickButton,
  }) : super(
          context: context,
          title: 'Incorrect email address or password.',
          description: 'Please try again, or reset your password at pandora.com.',
          buttonLabel: buttonLabel,
          onClickButton: onClickButton,
        );
}
