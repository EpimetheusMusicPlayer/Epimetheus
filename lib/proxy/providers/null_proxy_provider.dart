import 'package:epimetheus/libepimetheus/networking.dart';
import 'package:epimetheus/proxy/proxy_provider.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// This is used to supply no proxy, if a proxy configuration error is detected.
/// This should trigger the configuration UI.
class NullProxyProvider extends ProxyProvider {
  NullProxyProvider({
    @required SharedPreferences prefs,
    @required FlutterSecureStorage storage,
  }) : super(prefs: prefs, storage: storage);

  @override
  Future<Proxy> getProxy() => null;

  @override
  Future<void> invalidateCaches() async {}

  @override
  ProxyProviderUI buildConfigurationUI({Key key, BuildContext context}) => null;
}
