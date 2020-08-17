import 'package:epimetheus/proxy/providers/nordvpn/nordvpn_proxy_provider.dart';
import 'package:epimetheus/proxy/providers/simple/simple_proxy_provider.dart';
import 'package:epimetheus/proxy/proxy_manager.dart';
import 'package:epimetheus/proxy/proxy_provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProxyPreferencesPage extends StatefulWidget {
  @override
  _ProxyPreferencesPageState createState() => _ProxyPreferencesPageState();
}

class _ProxyPreferencesPageState extends State<ProxyPreferencesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proxy settings'),
      ),
      body: ListView(
        children: <Widget>[
          _ProxyInfo(),
          const SizedBox(height: 16),
          FutureBuilder<SharedPreferences>(
            future: SharedPreferences.getInstance(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();

              return _ProxyConfigurationUI(
                prefs: snapshot.data,
              );
            },
          )
        ],
      ),
    );
  }
}

class _ProxyInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Icon(
                Icons.info_outline,
                color: Colors.black54,
              ),
              title: const Text(
                'Most things will still use your system proxy settings. Tap here for more info.',
                style: const TextStyle(color: Colors.black54),
              ),
            ),
          ),
          Divider(height: 0),
        ],
      ),
      onTap: () {
        showDialog<void>(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: const Text(
                  'This proxy feature is designed to bypass Pandora\'s geo-blocks.\n\nPandora only enforces these blocks when signing in. The geo-blocks are not enforced when media, like audio and album art, is accessed, or when browsing music or viewing your collection.\n\nSince these things aren\'t geo-blocked, the proxy is not used for it.'),
              actions: <Widget>[
                FlatButton(
                  textColor: Theme.of(context).accentColor,
                  onPressed: () => Navigator.pop(context),
                  child: const Text('I understand'),
                )
              ],
            );
          },
        );
      },
    );
  }
}

class _ProxyConfigurationUI extends StatefulWidget {
  final SharedPreferences prefs;

  const _ProxyConfigurationUI({
    Key key,
    @required this.prefs,
  }) : super(key: key);

  @override
  _ProxyConfigurationUIState createState() => _ProxyConfigurationUIState();
}

class _ProxyConfigurationUIState extends State<_ProxyConfigurationUI> {
  static const _noProxyId = '';

  final _proxyConfigurationUIKey = GlobalKey<ProxyProviderUIState>();

  String _selectedProxyId;
  ProxyProvider _proxyProvider;

  @override
  void initState() {
    super.initState();
    _selectedProxyId = ProxyManager.getProxyProviderId(widget.prefs) ?? _noProxyId;
    _updateProxyProvider();
  }

  void _updateProxyProvider() {
    _proxyProvider = _selectedProxyId != _noProxyId ? ProxyManager.getProxyProviderFromId(widget.prefs, _selectedProxyId) : null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Proxy type',
                  ),
                  value: _selectedProxyId,
                  onChanged: (value) {
                    _selectedProxyId = value;
                    setState(() {
                      _updateProxyProvider();
                    });
                  },
                  items: [
                    DropdownMenuItem(
                      value: _noProxyId,
                      child: const Text('None'),
                    ),
                    DropdownMenuItem(
                      value: SimpleProxyProvider.id,
                      child: const Text('Manual'),
                    ),
                    DropdownMenuItem(
                      value: NordVPNProxyProvider.id,
                      child: const Text('NordVPN (account required)'),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              IconButton(
                icon: Icon(Icons.save),
                onPressed: () async {
                  bool saveStatus;
                  if (_proxyProvider == null) {
                    saveStatus = await ProxyManager.toggleProxy(widget.prefs, false);
                  } else {
                    saveStatus = await _proxyConfigurationUIKey.currentState.save() && await ProxyManager.toggleProxy(widget.prefs, true);
                  }
                  saveStatus = saveStatus && await ProxyManager.setProxyProviderId(widget.prefs, _selectedProxyId);
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text(saveStatus ? 'Save successful.' : 'Save unsuccessful.'),
                    ),
                  );
                },
              )
            ],
          ),
          const SizedBox(height: 8),
          if (_selectedProxyId != _noProxyId)
            _proxyProvider.buildConfigurationUI(
              key: _proxyConfigurationUIKey,
              context: context,
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
