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
  bool usePortaller;
  final String email;
  final String password;
  final String username;
  final String webname;
  final String profileImageUrl;

  User._internal({
    @required authToken,
    @required this.usePortaller,
    @required this.email,
    @required this.password,
    @required this.username,
    @required this.webname,
    @required this.profileImageUrl,
  }) : super._internal(authToken);

  /// Creates a user object, authenticating with the given [email] and [password].
  /// If the [usePortaller] boolean is true, the Portaller smart DNS service will be used.
  static Future<User> create(email, String password, [usePortaller = false]) async {
    var authResponse = await makeApiRequest(
      version: 'v1',
      endpoint: 'auth/login',
      requestData: {
        'username': email,
        'password': password,
        'keepLoggedIn': true,
      },
      usePortaller: usePortaller,
    );

    return User._internal(
      authToken: authResponse['authToken'],
      usePortaller: usePortaller,
      email: email,
      password: password,
      username: await _getUsername(AuthenticatedEntity._internal(authResponse['authToken']), authResponse['webname'], usePortaller),
      webname: authResponse['webname'],
      profileImageUrl: (await _getFacebookProfileImageUrl(authResponse['facebookData'])) ?? authResponse['placeholderProfileImageUrl'],
    );
  }

  static Future<String> _getUsername(AuthenticatedEntity auth, String webname, bool usePortaller) async {
    var userProfileResponse = await makeApiRequest(
      version: 'v1',
      endpoint: 'listener/getProfile',
      requestData: {'webname': webname},
      usePortaller: usePortaller,
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
  String toString() => 'usePortaller: $usePortaller, email: $email, username: $username, webname: $webname, profilePicUrl: $profileImageUrl';
}
