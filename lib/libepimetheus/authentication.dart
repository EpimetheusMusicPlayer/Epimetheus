import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import './networking.dart';

class AuthenticatedEntity {
  String _authToken;
  String get authToken => _authToken;

  // This proxy object is used to recreate the HTTP client if it becomes null.
  // The HTTP client needs to become null for the user to be sent through isolate nameservers.
  Proxy _proxy;

  http.BaseClient _proxyClient;
  http.BaseClient get proxyClient => _proxyClient ??= (_proxy?.toClient() ?? http.Client());

  AuthenticatedEntity._internal(this._authToken, this._proxyClient, this._proxy);

  void discardClient() {
    // Discard the client to be recreated when next used
    _proxyClient = null;
  }
}

/// [User] class, required for all api calls.
class User extends AuthenticatedEntity {
  final String email;
  final String password;
  final String username;
  final String webname;
  final String profileImageUrl;

  User._internal({
    @required Proxy proxy,
    @required http.BaseClient client,
    @required authToken,
    @required this.email,
    @required this.password,
    @required this.username,
    @required this.webname,
    @required this.profileImageUrl,
  }) : super._internal(authToken, client, proxy);

  /// Creates a user object, authenticating with the given [email] and [password].
  /// If the [useProxy] boolean is true, a proxy service will be used.
  static Future<User> create({
    @required email,
    @required String password,
    Proxy proxy,
  }) async {
    // Create a HTTP client with the correct proxy settings.
    final proxyClient = proxy == null ? http.Client() : proxy.toClient();

    final authResponse = await makeApiRequest(
      version: 'v1',
      endpoint: 'auth/login',
      requestData: {
        'username': email,
        'password': password,
        'keepLoggedIn': true,
      },
      anonymousProxyClient: proxyClient,
    );

    return User._internal(
      proxy: proxy,
      client: proxyClient,
      authToken: authResponse['authToken'],
      email: email,
      password: password,
      username: await _getUsername(AuthenticatedEntity._internal(authResponse['authToken'], proxyClient, proxy), authResponse['webname']),
      webname: authResponse['webname'],
      profileImageUrl: (await _getFacebookProfileImageUrl(authResponse['facebookData'])) ?? authResponse['placeholderProfileImageUrl'],
    );
  }

  Future<void> reauthenticate() async {
    _authToken = (await makeApiRequest(
      version: 'v1',
      endpoint: 'auth/login',
      requestData: {
        'username': email,
        'password': password,
        'keepLoggedIn': true,
        'existingAuthToken':
            _authToken, // I think this is used when the web client's webpage is reloaded. The API seems to just spit this value out again when supplied. It could, however, be used to refresh the token.
      },
      anonymousProxyClient: proxyClient,
    ))['authToken'];
  }

  User clone() {
    return User._internal(
      proxy: _proxy,
      client: _proxyClient,
      authToken: _authToken,
      email: email,
      password: password,
      username: username,
      webname: webname,
      profileImageUrl: profileImageUrl,
    );
  }

  static Future<String> _getUsername(AuthenticatedEntity auth, String webname) async {
    var userProfileResponse = await makeApiRequest(
      version: 'v1',
      endpoint: 'listener/getProfile',
      requestData: {'webname': webname},
      user: auth,
    );

    return userProfileResponse.containsKey('fullName') ? userProfileResponse['fullName'] : userProfileResponse['webname'];
  }

  static Future<String> _getFacebookProfileImageUrl(Map<String, dynamic> facebookData) async {
    if (facebookData == null) return null;

    return jsonDecode(
      (await http.get(
        Uri(
          scheme: 'https',
          host: 'graph.facebook.com',
          pathSegments: [facebookData['facebookId'], 'picture'],
          queryParameters: {
            'type': 'large',
            'redirect': 'false',
          },
        ),
      ))
          .body,
    )['data']['url'];
  }

  @override
  String toString() => 'email: $email, username: $username, webname: $webname, profilePicUrl: $profileImageUrl';
}
