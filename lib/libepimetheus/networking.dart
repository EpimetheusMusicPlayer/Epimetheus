import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import './authentication.dart';
import './exceptions.dart';

String csrfToken;
final Dio _dio = Dio();
final Dio _portallerDio = () {
  final Dio _portallerDio = Dio();
  (_portallerDio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
    client.badCertificateCallback = (cert, host, port) {
      print('bad cert');
      print(cert.issuer);
      print(cert.subject);
      print(host);
      return true;
    };
  };
  _portallerDio.interceptors.add(InterceptorsWrapper(
    onError: (error) {
      print('error');
      print(error);
    },
  ));
  return _portallerDio;
}();

/// Make a Pandora API request.
Future<Map<String, dynamic>> makeApiRequest({
  @required String version,
  @required String endpoint,
  Map<String, dynamic> requestData = const {},
  bool usePortaller = false,
  AuthenticatedEntity user,
}) async {
  final response = (await _portallerDio.post(
    'https://107.170.15.247/api/$version/$endpoint',
    options: Options(responseType: ResponseType.json, headers: {
      'Host': 'pandora.com',
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

  for (String string in (await _portallerDio.head(
    'https://107.170.15.247/',
    options: Options(
      headers: {
        'Host': 'pandora.com',
      },
    ),
  ))
      .headers['set-cookie']) {
    if (string.startsWith('csrftoken')) {
      _csrfToken = string.split('=')[1].split(';')[0];
    }
  }

  if (_csrfToken == null) {
    throw LocationException();
  }

  return _csrfToken;
}
