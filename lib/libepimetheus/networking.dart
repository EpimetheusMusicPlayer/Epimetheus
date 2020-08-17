import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';

import './authentication.dart';
import './exceptions.dart';

final _client = Client();
String csrfToken; // = 'a8df2bc28855ddd3';

/// Make a Pandora API request.
/// [version] is used to select the Pandora API version, e.g. v1.
/// [endpoint] is the API endpoint, e.g. auth/login.
/// [requestData] is the POST body.
/// [user] is the [User] to use.
/// [anonymousProxyClient] is the http client to use if no user is supplied.
/// [needsProxy] tells the function if the endpoint is geo-blocked.
Future<Map<String, dynamic>> makeApiRequest({
  @required String version,
  @required String endpoint,
  Map<String, dynamic> requestData = const {},
  AuthenticatedEntity user,
  BaseClient anonymousProxyClient,
  bool needsProxy = false,
}) async {
  print('$version/$endpoint');

  final proxyClient = user?.proxyClient ?? anonymousProxyClient;
  final client = needsProxy ? proxyClient : _client;

  final response = await client.post(
    'https://www.pandora.com/api/$version/$endpoint',
    encoding: utf8,
    body: jsonEncode(requestData),
    headers: {
      'Content-Type': 'application/json',
      'Cookie': 'csrftoken=${csrfToken ??= await getCsrfToken(proxyClient)}', // _gat=1 may be necessary also
      'X-CsrfToken': csrfToken, // The csrfToken is definitely initialised due to the line above
      'X-AuthToken': user?.authToken ?? '',
    },
  );

  final Map<String, dynamic> responseJSON = jsonDecode(response.body);

  if (response.statusCode != 200) {
    throwException(
      responseJSON['errorString'],
      responseJSON['message'],
      responseJSON['errorCode'],
      response.statusCode,
      '$version/$endpoint',
    );
  }

  return responseJSON;
}

Future<String> getCsrfToken(BaseClient proxyClient) async {
  print('Getting csrfToken');

  String _csrfToken;

//  final headers = (await proxyClient.head('https://www.pandora.com/')).headers;
  final headers = (await proxyClient.send(
    Request(
      'HEAD',
      Uri.parse('https://www.pandora.com/'),
    ),
  ))
      .headers;

  print('Got headers');

  if (headers.containsKey('set-cookie')) {
    for (String string in headers['set-cookie'].split(RegExp(r';|,'))) {
      if (string.startsWith('csrftoken')) {
        _csrfToken = string.split('=')[1];
      }
    }

    if (_csrfToken == null) {
      throw LocationException();
    }
  } else {
    throw LocationException();
  }

  return _csrfToken;
}

class Proxy {
  final String host;
  final int port;
  final String username;
  final String password;
  final bool ignoreSSLErrors;

  const Proxy({
    @required this.host,
    @required this.port,
    this.username,
    this.password,
    this.ignoreSSLErrors = false,
  });

  BaseClient toClient() {
    final httpClient = HttpClient()
      ..findProxy = ((uri) {
        return 'PROXY $host:$port';
      });

    if (username != null) {
      httpClient.addProxyCredentials(
        host,
        port,
        'pandora.com',
        HttpClientBasicCredentials(
          username,
          password,
        ),
      );
    }

    if (ignoreSSLErrors) httpClient.badCertificateCallback = (cert, host, port) => true;

    return IOClient(httpClient);
  }
}
