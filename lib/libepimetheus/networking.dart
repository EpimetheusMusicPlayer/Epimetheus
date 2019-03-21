import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  Map<String, dynamic> response = jsonDecode((await http.post(
    Uri(
      scheme: 'https',
      host: 'pandora.com',
      pathSegments: ['api', version] + endpoint.split('/'),
    ),
    encoding: Encoding.getByName('utf-8'),
    body: jsonEncode(requestData),
    headers: {
      'Content-Type': 'application/json',
      'Cookie': 'csrftoken=${csrfToken ??= await getCsrfToken()}',
      'X-CsrfToken': csrfToken ??= await getCsrfToken(),
      'X-AuthToken': user?.authToken ?? '',
    },
  ))
      .body);

  if (response.containsKey('errorCode')) throwException(response['errorString'], response['message'], response['errorCode']);

  return response;
}

Future<String> getCsrfToken() async {
  String _csrfToken;

  for (String string in (await http.head('https://pandora.com/')).headers['set-cookie'].split(RegExp(r';|,'))) {
    if (string.startsWith('csrftoken')) {
      _csrfToken = string.split('=')[1];
    }
  }

  if (_csrfToken == null) {
    throw LocationException();
  }

  return _csrfToken;
}
