import 'package:epimetheus/features/proxy/ui/widgets/provider_uis/authonly.dart';
import 'package:epimetheus/features/proxy/ui/widgets/provider_uis/manual.dart';
import 'package:epimetheus/features/proxy/ui/widgets/proxy_info_list_tile.dart';
import 'package:epimetheus_nullable/mobx/proxy/proxy_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:pedantic/pedantic.dart';
import 'package:proxies/proxies.dart';

class ProxyPreferencesPage extends StatefulWidget {
  const ProxyPreferencesPage();

  @override
  _ProxyPreferencesPageState createState() => _ProxyPreferencesPageState();
}

class _ProxyPreferencesPageState extends State<ProxyPreferencesPage> {
  final _proxyStore = GetIt.instance<ProxyStore>();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (!_proxyStore.loaded) _proxyStore.load();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final formState = _formKey.currentState;
        if (formState == null) return true; // Allow to exit if there's no form.
        if (formState.validate()) {
          formState.save();
          unawaited(_proxyStore.save());
          return true;
        } else {
          return false;
        }
      },
      child: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Proxy preferences'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _proxyStore.refresh,
              ),
            ],
          ),
          body: Observer(
            builder: (context) {
              if (_proxyStore.loading) return const SizedBox();

              final Type? selectedProvider = _proxyStore.selectedProvider;
              return Column(
                children: [
                  const ProxyInfoListTile(),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Proxy type',
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Type>(
                          items: const [
                            DropdownMenuItem(
                              value: null,
                              child: Text('None'),
                            ),
                            DropdownMenuItem(
                              value: SimpleProxyProvider,
                              child: Text('Manual'),
                            ),
                            DropdownMenuItem(
                              value: NordVPNProxyProvider,
                              child: Text('NordVPN'),
                            ),
                          ],
                          value: selectedProvider,
                          isDense: true,
                          onChanged: (providerType) {
                            _proxyStore.changeProvider(providerType);
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Builder(
                      builder: (context) {
                        switch (selectedProvider) {
                          case null:
                            return const SizedBox();
                          case SimpleProxyProvider:
                            return ManualProviderUI(
                              proxyStore: _proxyStore,
                              formKey: _formKey,
                            );
                          case NordVPNProxyProvider:
                            return AuthOnlyProviderUI(
                              proxyStore: _proxyStore,
                              formKey: _formKey,
                            );
                          default:
                            throw UnimplementedError(
                              'Selected proxy provider ($selectedProvider) is unimplemented!',
                            );
                        }
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
