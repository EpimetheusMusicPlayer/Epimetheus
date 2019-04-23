import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import './networking.dart';

class AuthenticatedEntity {
  final String authToken;

  AuthenticatedEntity._internal(this.authToken);
}

/// [User] class, required for all api calls.
class User extends AuthenticatedEntity {
  bool useProxy;
  final String email;
  final String password;
  final String username;
  final String webname;
  final String profileImageUrl;

  User._internal({
    @required authToken,
    @required this.useProxy,
    @required this.email,
    @required this.password,
    @required this.username,
    @required this.webname,
    @required this.profileImageUrl,
  }) : super._internal(authToken);

  /// Creates a user object, authenticating with the given [email] and [password].
  /// If the [useProxy] boolean is true, a proxy service will be used.
  static Future<User> create(email, String password, [useProxy = false]) async {
    var authResponse = await makeApiRequest(
      version: 'v1',
      endpoint: 'auth/login',
      requestData: {
        'username': email,
        'password': password,
        'keepLoggedIn': true,
      },
      useProxy: useProxy,
    );

    return User._internal(
      authToken: authResponse['authToken'],
      useProxy: useProxy,
      email: email,
      password: password,
      username: await _getUsername(AuthenticatedEntity._internal(authResponse['authToken']), authResponse['webname'], useProxy),
      webname: authResponse['webname'],
      profileImageUrl: (await _getFacebookProfileImageUrl(authResponse['facebookData'])) ?? authResponse['placeholderProfileImageUrl'],
    );
  }

  static Future<String> _getUsername(AuthenticatedEntity auth, String webname, bool usePortaller) async {
    var userProfileResponse = await makeApiRequest(
      version: 'v1',
      endpoint: 'listener/getProfile',
      requestData: {'webname': webname},
      useProxy: usePortaller,
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
  String toString() => 'usePortaller: $useProxy, email: $email, username: $username, webname: $webname, profilePicUrl: $profileImageUrl';
}
