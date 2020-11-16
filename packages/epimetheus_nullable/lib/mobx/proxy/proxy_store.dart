import 'package:epimetheus/features/proxy/data/secure_storage.dart';
import 'package:mobx/mobx.dart';
import 'package:proxies/proxies.dart';

part 'proxy_store.g.dart';

class ProxyStore = _ProxyStore with _$ProxyStore;

abstract class _ProxyStore with Store {
  SecureStorage _storage;

  @observable
  Type selectedProvider;

  @observable
  bool loaded = false;

  @observable
  bool loading = false;

  @observable
  bool saving = false;

  String username;
  String password;
  String host;
  int port;

  Future<void> _ensureInitialized() async {
    _storage ??= await SecureStorage.create();
  }

  Future<void> changeProvider(Type providerType) async {
    await _storage.write('provider', _providerIds[providerType]);
    await load();
  }

  // TODO refreshing is currently ineffective
  // https://github.com/mobxjs/mobx.dart/issues/597
  Future<void> refresh() async {
    await load();
  }

  @action
  Future<void> load() async {
    loading = true;
    await _ensureInitialized();
    final name = await _storage.read('provider');
    if (name == null) {
      selectedProvider = null;
      username = null;
      password = null;
      host = null;
      port = null;
    } else {
      final creds = await Future.wait<String>([
        _storage.read('${name}_username'),
        _storage.read('${name}_password'),
        _storage.read('${name}_host'),
        _storage.read('${name}_port'),
      ]);
      selectedProvider = _providers[name];
      username = creds[0];
      password = creds[1];
      host = creds[2];
      port = creds[3] == null ? null : int.parse(creds[3], radix: 36);
    }
    loading = false;
    loaded = true;
  }

  @action
  Future<void> save() async {
    saving = true;
    final name = _providerIds[selectedProvider];
    await Future.wait<void>([
      _storage.write('provider', name),
      _storage.write('${name}_username', username),
      _storage.write('${name}_password', password),
      _storage.write('${name}_host', host),
      _storage.write('${name}_port', port?.toRadixString(36)),
    ]);
    saving = false;
  }

  ProxyProvider get proxyProvider {
    if (selectedProvider == null) return null;
    switch (selectedProvider) {
      case SimpleProxyProvider:
        return SimpleProxyProvider(host, port, username, password);
      case NordVPNProxyProvider:
        return NordVPNProxyProvider(
          username: username,
          password: password,
          countryCode: 'US',
        );
      default:
        throw UnimplementedError(
          'Proxy provider $selectedProvider is not implemented!',
        );
    }
  }

  static const _providerIds = {
    SimpleProxyProvider: 'simple',
    NordVPNProxyProvider: 'nordvpn',
  };

  static const _providers = {
    'simple': SimpleProxyProvider,
    'nordvpn': NordVPNProxyProvider,
  };
}
