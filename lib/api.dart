import 'dart:io';

import 'package:epimetheus/dialogs/api_error_dialog.dart';
import 'package:epimetheus/dialogs/no_connection_dialog.dart';
import 'package:epimetheus/libepimetheus/exceptions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// A simple wrapper to capture any Pandora API errors.

Future<dynamic> makeApiRequest({
  BuildContext context,
  Future<dynamic> Function() apiRequest,
}) async {
  try {
    return await apiRequest;
  } on SocketException {
    showDialog(context: context, builder: noConnectionDialog);
  } on PandoraException {
    showDialog(context: context, builder: apiErrorDialog);
  }
}
