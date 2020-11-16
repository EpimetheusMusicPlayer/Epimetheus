import 'package:epimetheus/core/ui/widgets/preference_header.dart';
import 'package:epimetheus_nullable/mobx/proxy/proxy_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ManualProviderUI extends StatefulWidget {
  final ProxyStore proxyStore;
  final GlobalKey<FormState> formKey;

  const ManualProviderUI({
    Key? key,
    required this.proxyStore,
    required this.formKey,
  }) : super(key: key);

  @override
  _ManualProviderUIState createState() => _ManualProviderUIState();
}

class _ManualProviderUIState extends State<ManualProviderUI> {
  late final TextEditingController _usernameController =
      TextEditingController(text: widget.proxyStore.username);
  late final TextEditingController _passwordController =
      TextEditingController(text: widget.proxyStore.password);
  late final TextEditingController _hostController =
      TextEditingController(text: widget.proxyStore.host);
  late final TextEditingController _portController =
      TextEditingController(text: widget.proxyStore.port?.toString());

  String? _validateHost(String? host) {
    if (host == null || host.isEmpty) return 'Host cannot be empty.';
  }

  String? _validatePort(String? port) {
    if (port == null || port.isEmpty) return 'Port cannot be empty.';
    if (int.tryParse(port) == null) return 'Port must be a number.';
  }

  String? _validateUsername(String? username) {}

  String? _validatePassword(String? password) {}

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AutofillGroup(
        child: Form(
          key: widget.formKey,
          child: Column(
            children: [
              const PreferenceHeader(
                'Server information',
                padding: EdgeInsets.only(bottom: 4),
              ),
              Row(
                children: <Widget>[
                  Flexible(
                    flex: 7,
                    child: TextFormField(
                      controller: _hostController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Host',
                      ),
                      keyboardType: TextInputType.url,
                      autofillHints: const [AutofillHints.url],
                      validator: _validateHost,
                      onSaved: (host) => widget.proxyStore.host = host,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    flex: 3,
                    child: TextFormField(
                      controller: _portController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Port',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: _validatePort,
                      onSaved: (port) => widget.proxyStore.port =
                          port == null ? null : int.parse(port),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const PreferenceHeader(
                'Authentication',
                padding: EdgeInsets.only(bottom: 4),
              ),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Username',
                ),
                keyboardType: TextInputType.text,
                autofillHints: const [AutofillHints.username],
                validator: _validateUsername,
                onSaved: (username) => widget.proxyStore.username = username,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
                obscureText: true,
                autofillHints: const [AutofillHints.password],
                validator: _validatePassword,
                onSaved: (password) => widget.proxyStore.password = password,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
