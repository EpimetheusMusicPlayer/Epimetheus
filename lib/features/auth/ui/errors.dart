import 'package:epimetheus/core/ui/widgets/error.dart';
import 'package:epimetheus/features/navigation/launchers/github.dart';
import 'package:epimetheus/features/proxy/entities/exceptions.dart';
import 'package:flutter/cupertino.dart';
import 'package:iapetus/iapetus.dart';

void showAuthErrorDialog(BuildContext context, dynamic error) {
  if (error is InvalidAuthException) {
    showErrorDialog(
      context: context,
      errorTitle: 'Incorrect email or password.',
      errorMessage: 'Please try again, or reset your password at pandora.com.',
      actionLabels: const ['Okay'],
      actions: [
        ({required closeErrorWindow}) {
          closeErrorWindow();
        },
      ],
    );
  } else if (error is IapetusNetworkException ||
      error is ProxyNetworkException) {
    showErrorDialog(
      context: context,
      errorTitle: 'Can\'t connect to Pandora.',
      errorMessage:
          'Are you connected to the Internet? Are your proxy settings correct?',
      actionLabels: const ['Back'],
      actions: [
        ({required closeErrorWindow}) {
          closeErrorWindow();
        },
      ],
    );
  } else if (error is LocationException) {
    showErrorDialog(
      context: context,
      errorTitle: 'You\'re outside the USA.',
      errorMessage: 'Use a VPN, proxy, or airplane to use the app.',
      actionLabels: const ['Okay'],
      actions: [
        ({required closeErrorWindow}) {
          closeErrorWindow();
        },
      ],
    );
  } else if (error is UnknownPandoraErrorException) {
    showErrorDialog(
      context: context,
      errorTitle: 'An unknown API error occurred.',
      errorMessage: error.toString(),
      actionLabels: const ['Back', 'Report'],
      actions: [
        ({required closeErrorWindow}) {
          closeErrorWindow();
        },
        ({required closeErrorWindow}) {
          launchApiGithubIssue(error);
          closeErrorWindow();
        },
      ],
    );
  } else if (error is ProxyAuthException) {
    showErrorDialog(
      context: context,
      errorTitle: 'Could not authenticate with the proxy service.',
      errorMessage: 'Verify that your proxy service credentials are correct.',
      actionLabels: const ['Back'],
      actions: [
        ({required closeErrorWindow}) {
          closeErrorWindow();
        },
      ],
    );
  } else if (error is ProxyNoneFoundException) {
    showErrorDialog(
      context: context,
      errorTitle: 'No proxy servers could be found.',
      errorMessage:
          'This may be caused by server issues, or you may not own a US proxy with the selected service.',
      actionLabels: const ['Back'],
      actions: [
        ({required closeErrorWindow}) {
          closeErrorWindow();
        },
      ],
    );
  } else if (error is ProxyUnknownException) {
    showErrorDialog(
      context: context,
      errorTitle: 'A proxy error has occurred.',
      errorMessage:
          'This can be caused by a bug in the proxy code, or by server issues.',
      actionLabels: const ['Back'],
      actions: [
        ({required closeErrorWindow}) {
          closeErrorWindow();
        },
      ],
    );
  } else {
    showErrorDialog(
      context: context,
      errorTitle: 'A critical application error has occurred.',
      errorMessage:
          'If this keeps happening, please report the issue on GitHub.\n\n${error}',
      actionLabels: const ['Back'],
      actions: [
        ({required closeErrorWindow}) {
          closeErrorWindow();
        },
      ],
    );
  }
}
