import 'dart:convert';

import 'package:epimetheus/libepimetheus/networking.dart';
import 'package:epimetheus/proxy/providers/nordvpn/nordvpn_proxy_provider_ui.dart';
import 'package:epimetheus/proxy/proxy_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A provider to use proxies from NordVPN's API.
class NordVPNProxyProvider extends ProxyProvider {
  static const id = 'nordvpn';
  static const _localStorageKeyPrefix = ProxyProvider.storageKeyPrefix + id + '_';

  static const _usernameKey = _localStorageKeyPrefix + 'username';
  static const _passwordKey = _localStorageKeyPrefix + 'password';

  Future<String> get username => storage.read(key: _usernameKey);

  Future<String> get password => storage.read(key: _passwordKey);

  NordVPNProxyProvider({
    @required SharedPreferences prefs,
    @required FlutterSecureStorage storage,
  }) : super(prefs: prefs, storage: storage);

  Future<bool> write({
    @required String username,
    @required String password,
  }) async {
    await Future.wait<void>([
      storage.write(key: _usernameKey, value: username),
      storage.write(key: _passwordKey, value: password),
    ]);
    return true;
  }

  String validateUsername(String username) => username.isEmpty ? 'Username is empty' : null;

  String validatePassword(String password) => password.isEmpty ? 'Password is empty' : null;

  @override
  Future<Proxy> getProxy() async {
    final password = await storage.read(key: _passwordKey);
    if (password == null) return null;

    final username = await storage.read(key: _usernameKey);
    if (username == null) return null;

    final servers = await getServers();
    for (final server in servers) {
      for (Map<String, dynamic> service in server['services']) {
        if (service['identifier'] == 'proxy') {
          return Proxy(
            host: '${server['hostname']}',
            port: 80,
            username: username,
            password: password,
          );
        }
      }
    }

    // This should never happen, but if it does, this should cause the settings to re-open.
    return null;
  }

  @override
  Future<void> invalidateCaches() async {
    // The NordVPN API is very fast. No caches are used, as it would be more expensive to check if the caches are still valid than to download a new server list.
  }

  Future<List<dynamic>> getServers() async {
    final requestURI = Uri(
      scheme: 'https',
      host: 'api.nordvpn.com',
      path: '/v1/servers/recommendations',
      queryParameters: const {
        'limit': '1', // The official chrome extension limits to 1. We do the same.
        'filters[servers_technologies][pivot][status]': 'online', // Not really sure what this does; copied from the Android app.
        'filters[country_id]': '228', // The US country id is 228. Full list at https://api.nordvpn.com/v1/servers/countries.
//        'filters[servers_technologies][identifier]': 'proxy_ssl',
//        'filters[servers_groups][identifier]': 'legacy_standard',
        'filters[servers_technologies][id]': '9',
        'filters[servers_technologies]': '9', // Either this query or the one above selects proxy servers. As most servers have proxy support anyway, and no official client does this, it's hard to tell which is correct.
      },
    );

    return jsonDecode((await get(requestURI)).body);
  }

  @override
  ProxyProviderUI<NordVPNProxyProvider> buildConfigurationUI({
    Key key,
    BuildContext context,
  }) =>
      NordVPNProxyProviderUI(key: key, provider: this);
}
