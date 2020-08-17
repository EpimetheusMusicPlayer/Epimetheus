import 'package:epimetheus/libepimetheus/networking.dart';
import 'package:epimetheus/proxy/providers/nordvpn/nordvpn_proxy_provider.dart';
import 'package:epimetheus/proxy/providers/null_proxy_provider.dart';
import 'package:epimetheus/proxy/providers/simple/simple_proxy_provider.dart';
import 'package:epimetheus/proxy/proxy_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// This class contains functions used to manage proxies for the app.
class ProxyManager {
  static const _proxyEnableKey = 'proxy_enable';
  static const _proxyProviderKey = 'proxy_provider';
  static const _storage = const FlutterSecureStorage();

  ProxyManager._();

  static bool isProxyEnabled(SharedPreferences prefs) {
    if (!prefs.containsKey(_proxyEnableKey)) toggleProxy(prefs, false);
    return prefs.getBool(_proxyEnableKey);
  }

  static Future<bool> toggleProxy(SharedPreferences prefs, bool enabled) {
    return prefs.setBool(_proxyEnableKey, enabled);
  }

  static Future<bool> setProxyProviderId(SharedPreferences prefs, String providerId) {
    return prefs.setString(_proxyProviderKey, providerId);
  }

  static String getProxyProviderId(SharedPreferences prefs) {
    if (!prefs.containsKey(_proxyProviderKey)) {
      assert(!isProxyEnabled(prefs));
      return null;
    }
    return prefs.getString(_proxyProviderKey);
  }

  static ProxyProvider getProxyProviderFromId(SharedPreferences prefs, String providerId) {
    switch (providerId) {
      case SimpleProxyProvider.id:
        return SimpleProxyProvider(
          prefs: prefs,
          storage: _storage,
        );
      case NordVPNProxyProvider.id:
        return NordVPNProxyProvider(
          prefs: prefs,
          storage: _storage,
        );
      default:
        return NullProxyProvider(
          prefs: prefs,
          storage: _storage,
        );
    }
  }

  static ProxyProvider getProxyProvider(SharedPreferences prefs) {
    return getProxyProviderFromId(prefs, getProxyProviderId(prefs));
  }

  /// Can return a null future, if no username or password is saved.
  static Future<Proxy> geProxy(SharedPreferences prefs) {
    assert(isProxyEnabled(prefs));
    return getProxyProvider(prefs).getProxy();
  }
}
