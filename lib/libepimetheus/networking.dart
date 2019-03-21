import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import './authentication.dart';
import './exceptions.dart';

String csrfToken;

/// Make a Pandora API request.
Future<Map<String, dynamic>> makeApiRequest({
  @required String version,
  @required String endpoint,
  Map<String, dynamic> requestData = const {},
  bool usePortaller = false,
  AuthenticatedEntity user,
}) async {
  var response = (await Dio().post(
    'https://pandora.com/api/$version/$endpoint',
    options: Options(responseType: ResponseType.json, headers: {
      'X-CsrfToken': csrfToken ??= await getCsrfToken(),
      'X-AuthToken': user?.authToken ?? '',
      'Cookie': 'csrftoken=${csrfToken ??= await getCsrfToken()}',
    }),
    data: requestData,
  ))
      .data;

  if (response.containsKey('errorCode')) throwException(response['errorString'], response['message'], response['errorCode']);
  return response;
}

Future<String> getCsrfToken() async {
  String _csrfToken;

  for (String string in (await Dio().head('https://pandora.com/')).headers['set-cookie']) {
    if (string.startsWith('csrftoken')) {
      _csrfToken = string.split('=')[1].split(';')[0];
    }
  }

  if (_csrfToken == null) {
    throw LocationException();
  }

  return _csrfToken;
}
