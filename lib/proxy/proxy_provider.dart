import 'package:epimetheus/libepimetheus/networking.dart';
import 'package:epimetheus/storage/secure_storage_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// This class defines functions all proxy providers must implement.
abstract class ProxyProvider {
  // Used by implementations to access storage keys
  static const storageKeyPrefix = 'proxy_provider_';

  final SharedPreferences prefs;
  final SecureStorageManager storage;

  ProxyProvider({
    @required this.prefs,
    @required this.storage,
  });

  /// Returns a [Proxy] object future, to be used for necessary network operations.
  Future<Proxy> getProxy();

  /// If the proxy provider caches lists of available proxies, invalidate those caches.
  Future<void> invalidateCaches();

  /// Called to build a UI used to configure the proxy settings.
  ProxyProviderUI<ProxyProvider> buildConfigurationUI({
    Key key,
    @required BuildContext context,
  });
}

abstract class ProxyProviderUI<T extends ProxyProvider> extends StatefulWidget {
  final T provider;

  const ProxyProviderUI({
    Key key,
    @required this.provider,
  }) : super(key: key);

  @override
  ProxyProviderUIState<ProxyProviderUI<T>> createState();
}

/// This class defines functions that all proxy configuration UIs must implement.
abstract class ProxyProviderUIState<T extends ProxyProviderUI> extends State<T> {
  /// Called when the widget's created to load saved settings.
  /// Return value based on load success.
  @protected
  Future<bool> load();

  /// Called to save the entered data.
  /// Return value based on save success.
  Future<bool> save();

  /// Called after loading the settings. Used to build the UI.
  @protected
  Widget buildUI(BuildContext context);

  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    load().then((successful) {
      if (successful && mounted) {
        setState(() {
          _loaded = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox();
    return buildUI(context);
  }
}
