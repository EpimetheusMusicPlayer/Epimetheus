import 'package:epimetheus/proxy/providers/simple/simple_proxy_provider.dart';
import 'package:epimetheus/proxy/proxy_provider.dart';
import 'package:epimetheus/widgets/misc/list_header.dart';
import 'package:flutter/material.dart';

class SimpleProxyProviderUI extends ProxyProviderUI<SimpleProxyProvider> {
  const SimpleProxyProviderUI({
    Key key,
    @required SimpleProxyProvider provider,
  }) : super(key: key, provider: provider);

  @override
  _SimpleProxyProviderUIState createState() => _SimpleProxyProviderUIState();
}

class _SimpleProxyProviderUIState extends ProxyProviderUIState<SimpleProxyProviderUI> {
  final _formKey = GlobalKey<FormState>();

  String _host;
  int _port;
  bool _authEnabled;
  String _username;
  String _password;

  TextEditingController _hostController;
  TextEditingController _portController;
  TextEditingController _usernameController;
  TextEditingController _passwordController;

  @override
  Future<bool> load() async {
    final pendingCreds = Future.wait<String>([
      widget.provider.username,
      widget.provider.password,
    ]);

    _hostController = TextEditingController(text: widget.provider.host);
    _portController = TextEditingController(text: widget.provider.port?.toString());
    _authEnabled = widget.provider.authEnabled ?? false;

    final creds = await pendingCreds;

    _usernameController = TextEditingController(text: creds[0]);
    _passwordController = TextEditingController(text: creds[1]);

    return true; // There's no way this should ever fail.
  }

  @override
  Future<bool> save() async {
    final formState = _formKey.currentState;
    if (formState.validate()) {
      _formKey.currentState.save();
      return await writeData();
    } else {
      return false;
    }
  }

  Future<bool> writeData() => widget.provider.write(
        host: _host,
        port: _port,
        authEnabled: _authEnabled,
        username: _username,
        password: _password,
      );

  @override
  Widget buildUI(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          const ListHeader('Server information', padding: EdgeInsets.zero),
          Row(
            children: <Widget>[
              Flexible(
                flex: 7,
                child: TextFormField(
                  controller: _hostController,
                  decoration: const InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Host',
                  ),
                  keyboardType: TextInputType.url,
                  validator: (host) => widget.provider.validateHost(host),
                  onSaved: (host) => _host = host,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                flex: 3,
                child: TextFormField(
                  controller: _portController,
                  decoration: const InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Port',
                  ),
                  keyboardType: TextInputType.number,
                  validator: widget.provider.validatePort,
                  onSaved: (port) => _port = int.parse(port),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const ListHeader(
            'Authentication',
            padding: EdgeInsets.only(bottom: 4),
          ),
          DropdownButtonFormField<bool>(
            value: _authEnabled,
            onChanged: (value) => setState(() => _authEnabled = value),
            decoration: const InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'Method',
            ),
            items: [
              const DropdownMenuItem(
                value: false,
                child: const Text('None'),
              ),
              const DropdownMenuItem(
                value: true,
                child: const Text('Credentials'),
              ),
            ],
          ),
          if (_authEnabled) const SizedBox(height: 8),
          if (_authEnabled)
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Username',
              ),
              keyboardType: TextInputType.text,
              validator: widget.provider.validateUsername,
              onSaved: (username) => _username = username,
            ),
          if (_authEnabled) const SizedBox(height: 8),
          if (_authEnabled)
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Password',
              ),
              obscureText: true,
              validator: widget.provider.validatePassword,
              onSaved: (password) => _password = password,
            ),
        ],
      ),
    );
  }
}
