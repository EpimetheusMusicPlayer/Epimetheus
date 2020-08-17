import 'package:epimetheus/proxy/providers/nordvpn/nordvpn_proxy_provider.dart';
import 'package:epimetheus/proxy/proxy_provider.dart';
import 'package:epimetheus/widgets/misc/list_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_autofill/flutter_autofill.dart';

class NordVPNProxyProviderUI extends ProxyProviderUI<NordVPNProxyProvider> {
  const NordVPNProxyProviderUI({
    Key key,
    @required NordVPNProxyProvider provider,
  }) : super(key: key, provider: provider);

  @override
  ProxyProviderUIState<ProxyProviderUI<NordVPNProxyProvider>> createState() => _NordVPNProxyProviderUIState();
}

class _NordVPNProxyProviderUIState extends ProxyProviderUIState<NordVPNProxyProviderUI> {
  final _formKey = GlobalKey<FormState>();

  bool _autofillCommited = false;

  String _username;
  String _password;

  TextEditingController _usernameController;
  TextEditingController _passwordController;

  @override
  Future<bool> load() async {
    final creds = await Future.wait<String>([
      widget.provider.username,
      widget.provider.password,
    ]);

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
        username: _username,
        password: _password,
      );

  @override
  Widget buildUI(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!_autofillCommited) FlutterAutofill.cancel();
        return true;
      },
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            const ListHeader(
              'Authentication',
              padding: EdgeInsets.only(bottom: 4),
            ),
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
            const SizedBox(height: 8),
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
      ),
    );
  }
}
