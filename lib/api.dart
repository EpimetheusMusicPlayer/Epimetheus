import 'dart:io';

import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:epimetheus/libepimetheus/exceptions.dart';
import 'package:epimetheus/libepimetheus/networking.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';

// A simple wrapper to capture any Pandora API errors.

Future<Map<String, dynamic>> makeCaughtApiRequest({
  @required String version,
  @required String endpoint,
  Map<String, dynamic> requestData = const {},
  AuthenticatedEntity user,
  BaseClient anonymousProxyClient,
  bool needsProxy = false,
  void Function(Exception) onNetworkError,
  void Function(Exception) onAPIError,
}) async {
  try {
    return await makeApiRequest(
      version: version,
      endpoint: endpoint,
      requestData: requestData,
      user: user,
      anonymousProxyClient: anonymousProxyClient,
      needsProxy: needsProxy,
    );
  } on SocketException catch (e) {
    onNetworkError?.call(e);
    return null;
  } on PandoraException catch (e) {
    onAPIError?.call(e);
    return null;
  }
}
