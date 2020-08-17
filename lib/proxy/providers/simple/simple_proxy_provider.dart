import 'package:epimetheus/libepimetheus/networking.dart';
import 'package:epimetheus/proxy/providers/simple/simple_proxy_provider_ui.dart';
import 'package:epimetheus/proxy/proxy_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SimpleProxyProvider extends ProxyProvider {
  static const id = 'simple';
  static const _localStorageKeyPrefix = ProxyProvider.storageKeyPrefix + id + '_';

  static const _hostKey = _localStorageKeyPrefix + 'host';
  static const _portKey = _localStorageKeyPrefix + 'triwizardcup';
  static const _authEnabledKey = _localStorageKeyPrefix + 'authEnabled';
  static const _usernameKey = _localStorageKeyPrefix + 'username';
  static const _passwordKey = _localStorageKeyPrefix + 'password';

  String get host => prefs.getString(_hostKey);

  int get port => prefs.getInt(_portKey);

  bool get authEnabled => prefs.getBool(_authEnabledKey);

  Future<String> get username => storage.read(key: _usernameKey);

  Future<String> get password => storage.read(key: _passwordKey);

  SimpleProxyProvider({
    @required SharedPreferences prefs,
    @required FlutterSecureStorage storage,
  }) : super(prefs: prefs, storage: storage);

  Future<bool> write({
    @required String host,
    @required int port,
    @required bool authEnabled,
    @required String username,
    @required String password,
  }) async {
    final results = await Future.wait<dynamic>([
      prefs.setString(_hostKey, host),
      prefs.setInt(_portKey, port),
      prefs.setBool(_authEnabledKey, authEnabled),
      authEnabled
          ? Future.wait<void>([
              storage.write(key: _usernameKey, value: username),
              storage.write(key: _passwordKey, value: password),
            ])
          : Future.wait<void>([
              storage.delete(key: _usernameKey),
              storage.delete(key: _passwordKey),
            ]),
    ]);

    return results[0] && results[1] && results[2];
  }

  String validateHost(String host) {
    String validateHostnameOrIP(String host) {
      // Thanks to these RegEx gods: https://stackoverflow.com/questions/106179/regular-expression-to-match-dns-hostname-or-ip-address
      // Note: must confirm this is RegEx and not an ancient alien language, because I can't tell the difference ATM.
      if (!RegExp(r"^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$").hasMatch(host) && !RegExp(r"(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}").hasMatch(host)) {
        return 'Host is not valid.';
      }
      return null;
    }

    if (host.isEmpty) return 'No host given.';
    if (host.contains('@') || host.contains(':')) return 'Invalid characters in hostname';
    return validateHostnameOrIP(host);
  }

  String validatePort(String port) {
    if (port.isEmpty) return 'No port given.';
    final parsedPort = int.tryParse(port);
    if (parsedPort == null) return 'Invalid port.';
    if (parsedPort.isNegative) return 'Port must be positive.';
    if (parsedPort == 0) return 'Port cannot be zero.';
    return null;
  }

  String validateUsername(String username) {
    return null;
  }

  String validatePassword(String password) {
    return null;
  }

  @override
  Future<Proxy> getProxy() async {
    if (host == null) return null;
    if (port == null) return null;

    return Proxy(
      host: host,
      port: port,
      username: await username,
      password: await password,
    );
  }

  @override
  Future<void> invalidateCaches() async {
    // N/A, no network operations are done by this provider.
  }

  @override
  ProxyProviderUI<SimpleProxyProvider> buildConfigurationUI({
    Key key,
    @required BuildContext context,
  }) =>
      SimpleProxyProviderUI(key: key, provider: this);
}
