import 'dart:io';

import 'package:epimetheus/libepimetheus/exceptions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// A simple wrapper to capture any Pandora API errors.

Future<dynamic> makeApiRequest({
  @required BuildContext context,
  @required Future<dynamic> Function() apiRequest,
  @required void Function(Exception) onNetworkError,
  @required void Function(Exception) onAPIError,
}) async {
  try {
    return await apiRequest;
  } on SocketException catch (e) {
    onNetworkError(e);
  } on PandoraException catch (e) {
    onAPIError(e);
  }
}
