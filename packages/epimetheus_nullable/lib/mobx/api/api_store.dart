import 'package:epimetheus/logging.dart';
import 'package:epimetheus_nullable/mobx/proxy/proxy_store.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iapetus/iapetus.dart';
import 'package:mobx/mobx.dart';

part 'api_store.g.dart';

class ApiStore = _ApiStore with _$ApiStore;

abstract class _ApiStore with Store {
  static const _logTag = '[API (MAIN)]';

  final ProxyStore _proxyStore;

  _ApiStore({@required ProxyStore proxyStore}) : _proxyStore = proxyStore;

  final logger = createLogger(_logTag);

  @observable
  Iapetus api;

  @computed
  bool get apiInitialized => api != null;

  bool get loggedIn => api.isAuthenticated;

  /// Closes storage objects.
  /// This may or may not be awaited as it's generally called upon an app exit.
  Future<void> dispose() async {
    await (api?.storage as HiveIapetusStorage).close();
  }

  @action
  Future<void> initializeApi() async {
    final storage = HiveIapetusStorage(hiveInit: Hive.initFlutter);
    await storage.open();
    api = Iapetus(
      storage: storage,
      logger: kDebugMode
          ? (level, messageBuilder) => logger.log(level, messageBuilder())
          : null,
    );
  }

  Future<void> configureProxy() async {
    assert(apiInitialized, 'Cannot set a proxy - API not initialized!');
    if (!_proxyStore.loaded) await _proxyStore.load();
    final proxy = await _proxyStore.proxyProvider?.getProxy();
    api.proxyConfiguration = proxy?.configuration ?? 'DIRECT';
  }
}
