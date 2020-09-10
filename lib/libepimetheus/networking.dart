import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import './authentication.dart';
import './exceptions.dart';

final _dio = Dio();
String csrfToken;

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
  @required AuthenticatedEntity user,
  bool needsProxy = false,
}) async {
  final responseJSON = _makeApiRequest(
    version: version,
    endpoint: endpoint,
    headers: {'X-AuthToken': user.authToken},
    requestData: requestData,
    proxyDio: user.proxyDio,
    needsProxy: needsProxy,
    apiHost: user.apiHost,
    onError: (responseJSON, errorCode) async {
      if (errorCode == 1001) {
        print('Auth token out-of-date; reauthenticating.');
        await (user as User).reauthenticate();
        return await makeApiRequest(
          version: version,
          endpoint: endpoint,
          requestData: requestData,
          user: user,
          needsProxy: needsProxy,
        );
      } else {
        return null;
      }
    },
  );

  return responseJSON;
}

/// Like [makeApiRequest], but used before a [User] is available.
Future<Map<String, dynamic>> makeAnonymousApiRequest({
  @required String version,
  @required String endpoint,
  Map<String, dynamic> requestData = const {},
  Dio proxyDio,
  bool needsProxy = false,
  @required String apiHost,
}) async {
  return _makeApiRequest(
    version: version,
    endpoint: endpoint,
    headers: const {},
    requestData: requestData,
    proxyDio: proxyDio,
    needsProxy: needsProxy,
    apiHost: apiHost,
  );
}

Future<Map<String, dynamic>> _makeApiRequest({
  @required String version,
  @required String endpoint,
  @required Map<String, String> headers,
  @required Map<String, dynamic> requestData,
  @required Dio proxyDio,
  @required bool needsProxy,
  @required String apiHost,
  Future<Map<String, dynamic>> Function(Map<String, dynamic> responseJSON, int errorCode) onError,
}) async {
  final client = needsProxy ? proxyDio : _dio;
  final token = csrfToken ??= await getCsrfToken(proxyDio, apiHost);

  print('Sending $version/$endpoint: $requestData');

  Future<Map<String, dynamic>> throwError(Response<dynamic> response) async {
    final errorCode = response.data['errorCode'];
    final errorResult = await onError?.call(response.data, errorCode);
    if (errorResult != null) return errorResult;
    throwException(
      response.data['errorString'],
      response.data['message'],
      errorCode,
      response.statusCode,
      '$version/$endpoint',
    );
    return null;
  }

  try {
    final response = await client.post<Map<String, dynamic>>(
      'https://$apiHost/api/$version/$endpoint',
      options: RequestOptions(
        data: requestData,
        headers: {
          'Content-Type': 'application/json',
          if (!kIsWeb) 'Cookie': 'csrftoken=$token', // _gat=1 may be necessary also
          'X-CsrfToken': csrfToken, // The csrfToken is definitely initialised due to the line above
        }..addAll(headers),
        responseType: ResponseType.json,
      ),
    );

    if (response.data.containsKey('errorCode') || response.statusCode != 200) {
      return await throwError(response);
    }

    print('Received $version/$endpoint: $requestData');

    return response.data;
  } on DioError catch (e) {
    if (e.response == null) throw e;
    return await throwError(e.response);
  }
}

// A simple wrapper to capture any Pandora API errors.
Future<Map<String, dynamic>> makeCaughtApiRequest({
  @required String version,
  @required String endpoint,
  Map<String, dynamic> requestData = const {},
  @required AuthenticatedEntity user,
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

Future<String> getCsrfToken(Dio proxyDio, String apiHost) async {
  String _csrfToken;

  final response = (await proxyDio.head('https://$apiHost/'));

  // If on the web, the CORS stripper proxy should use the following token automatically.
  if (kIsWeb) return 'a553a9a4a5f45112';

  if (response.headers.map.containsKey('set-cookie')) {
    for (String string in response.headers['set-cookie']) {
      if (string.startsWith('csrftoken')) {
        _csrfToken = string.split(';')[0].split('=')[1];
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

  Dio toDio() {
    assert(!(host.contains('@') || host.contains(':')));

    String authPrefix;
    if (username != null) {
      authPrefix = Uri.encodeComponent(username);
      if (password != null) authPrefix += ':' + Uri.encodeComponent(password);
      authPrefix += '@';
    }

    final dio = Dio();
    // TODO proxy support on web
    if (!kIsWeb)
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
        client.findProxy = (uri) {
          return 'PROXY ${authPrefix ?? ''}$host:$port';
        };

        if (ignoreSSLErrors) client.badCertificateCallback = (cert, host, port) => true;
      };

    return dio;
  }
}
