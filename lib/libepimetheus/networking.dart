import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';

import './authentication.dart';
import './exceptions.dart';

String csrfToken;
final _proxyClient = IOClient(
  HttpClient()..findProxy = (uri) => uri.host.contains('pandora.com') ? 'PROXY 173.249.43.105:3128' : 'DIRECT',
);

BaseClient client = IOClient();

/// Make a Pandora API request.
Future<Map<String, dynamic>> makeApiRequest({
  @required String version,
  @required String endpoint,
  Map<String, dynamic> requestData = const {},
  bool useProxy = false,
  AuthenticatedEntity user,
}) async {
  final postFunction = useProxy ? _proxyClient.post : client.post;
  final Map<String, dynamic> response = jsonDecode((await postFunction(
    'https://www.pandora.com/api/$version/$endpoint',
    encoding: Encoding.getByName('utf-8'),
    body: jsonEncode(requestData),
    headers: {
      'Content-Type': 'application/json',
      'Cookie': 'csrftoken=${csrfToken ??= await getCsrfToken(useProxy)}',
      'X-CsrfToken': csrfToken ??= await getCsrfToken(useProxy),
      'X-AuthToken': user?.authToken ?? '',
    },
  ))
      .body);

  if (response.containsKey('errorCode')) throwException(response['errorString'], response['message'], response['errorCode']);

  return response;
}

Future<String> getCsrfToken(bool useProxy) async {
  String _csrfToken;

  final headFunction = useProxy ? _proxyClient.head : client.head;

  for (String string in (await headFunction('https://pandora.com/')).headers['set-cookie'].split(RegExp(r';|,'))) {
    if (string.startsWith('csrftoken')) {
      _csrfToken = string.split('=')[1];
    }
  }

  if (_csrfToken == null) {
    throw LocationException();
  }

  return _csrfToken;
}
