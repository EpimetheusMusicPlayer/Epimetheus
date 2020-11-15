import 'dart:io';

import 'package:epimetheus/core/ui/error.dart';
import 'package:flutter/widgets.dart';
import 'package:iapetus/iapetus.dart';

bool handleCoreErrors({
  required BuildContext context,
  required Object error,
  required UIErrorMessageCallback showErrorMessage,
  required void Function(String routeName) navigateTo,
}) {
  if (error is IapetusNetworkException || error is SocketException) {
    showErrorMessage(
      context: context,
      errorTitle: 'Can\'t connect to Pandora.',
      errorMessage: 'Are you connected to the Internet?',
      actionLabels: const ['Okay'],
      actions: [({required closeErrorWindow}) => closeErrorWindow()],
    );
    return true;
  }

  return false;
}
