import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

import './networking.dart';

enum SubscriptionType {
  free,
  premium,
}

SubscriptionType _getSubscriptionType(String branding) {
  if (branding == "PandoraPremium") return SubscriptionType.premium;
  return SubscriptionType.free;
}

class AuthenticatedEntity {
  /// The [apiHost] is usually www.pandora.com, but this must change in the web
  /// app due to CORS. This is intended to point to something like CORSflare for Pandora:
  /// https://github.com/EpimetheusMusicPlayer/CORSflare-for-Pandora
  final String apiHost;

  String _authToken;

  String get authToken => _authToken;

  // This proxy object is used to recreate the HTTP client if it becomes null.
  // The HTTP client needs to become null for the user to be sent through isolate nameservers.
  Proxy _proxy;

  Dio _proxyDio;

  Dio get proxyDio => _proxyDio ??= (_proxy?.toDio() ?? Dio());

  AuthenticatedEntity._internal(this._authToken, this._proxyDio, this._proxy, this.apiHost);

  void discardClient() {
    // Discard the client to be recreated when next used
    // Useful as the client cannot be passed to an isolate
    _proxyDio = null;
  }
}

/// [User] class, required for all api calls.
class User extends AuthenticatedEntity {
  final String email;
  final String password;
  final String username;
  final String webname;
  final String profileImageUrl;
  final String webClientVersion;

  SubscriptionType _subscriptionType;

  SubscriptionType get subscriptionType => _subscriptionType;

  bool _hasHighQualityStreaming;

  bool get hasHighQualityStreaming => _hasHighQualityStreaming;

  User._internal({
    @required Proxy proxy,
    @required Dio proxyDio,
    @required authToken,
    @required this.email,
    @required this.password,
    @required this.username,
    @required this.webname,
    @required this.profileImageUrl,
    @required SubscriptionType subscriptionType,
    @required bool hasHighQualityStreaming,
    @required this.webClientVersion,
    @required String apiHost,
  })  : _subscriptionType = subscriptionType,
        _hasHighQualityStreaming = hasHighQualityStreaming,
        super._internal(authToken, proxyDio, proxy, apiHost);

  /// Creates a user object, authenticating with the given [email] and [password].
  /// If the [useProxy] boolean is true, a proxy service will be used.
  static Future<User> create({
    @required email,
    @required String password,
    Proxy proxy,
    String apiHost = 'www.pandora.com',
  }) async {
    // Create a HTTP client with the correct proxy settings.
    final proxyDio = proxy == null ? Dio() : proxy.toDio();

    final authResponse = await makeAnonymousApiRequest(
      version: 'v1',
      endpoint: 'auth/login',
      requestData: {
        'username': email,
        'password': password,
        'keepLoggedIn': true,
      },
      proxyDio: proxyDio,
      apiHost: apiHost,
    );

    return User._internal(
      proxy: proxy,
      proxyDio: proxyDio,
      authToken: authResponse['authToken'],
      email: email,
      password: password,
      username: await _getUsername(AuthenticatedEntity._internal(authResponse['authToken'], proxyDio, proxy, apiHost), authResponse['webname']),
      webname: authResponse['webname'],
      profileImageUrl: (await _getFacebookProfileImageUrl(authResponse['facebookData'])) ?? authResponse['placeholderProfileImageUrl'],
      subscriptionType: _getSubscriptionType(authResponse['config']['branding']),
      hasHighQualityStreaming: authResponse['highQualityStreamingEnabled'],
      webClientVersion: authResponse['webClientVersion'],
      apiHost: apiHost,
    );
  }

  Future<void> reauthenticate() async {
    final response = await makeAnonymousApiRequest(
      version: 'v1',
      endpoint: 'auth/login',
      requestData: {
        'username': email,
        'password': password,
        'keepLoggedIn': true,
        'existingAuthToken': _authToken, // I think this is used when the web client's webpage is reloaded. The API seems to just spit this value out again when supplied. It could, however, be used to refresh the token.
      },
      proxyDio: proxyDio,
      apiHost: apiHost,
    );

    _authToken = response['authToken'];
    _subscriptionType = _getSubscriptionType(response['config']['branding']);
    _hasHighQualityStreaming = response['hasHighQualityStreaming'];
  }

  User clone() {
    return User._internal(
      proxy: _proxy,
      proxyDio: _proxyDio,
      authToken: _authToken,
      email: email,
      password: password,
      username: username,
      webname: webname,
      profileImageUrl: profileImageUrl,
      subscriptionType: subscriptionType,
      hasHighQualityStreaming: hasHighQualityStreaming,
      webClientVersion: webClientVersion,
      apiHost: apiHost,
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

    return (await Dio().getUri<Map<String, dynamic>>(
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
        .data['data']['url'];
  }

  @override
  String toString() => 'email: $email, username: $username, webname: $webname, profilePicUrl: $profileImageUrl';
}
