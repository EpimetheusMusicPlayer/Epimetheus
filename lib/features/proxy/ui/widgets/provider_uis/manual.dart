import 'package:epimetheus/core/ui/widgets/preference_header.dart';
import 'package:epimetheus_nullable/mobx/proxy/proxy_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ManualProviderUI extends StatelessWidget {
  final ProxyStore proxyStore;
  final GlobalKey<FormState> formKey;

  const ManualProviderUI({
    Key? key,
    required this.proxyStore,
    required this.formKey,
  }) : super(key: key);

  static String? _validateHost(String? host) {
    if (host == null || host.isEmpty) return 'Host cannot be empty.';
  }

  static String? _validatePort(String? port) {
    if (port == null || port.isEmpty) return 'Port cannot be empty.';
    if (int.tryParse(port) == null) return 'Port must be a number.';
  }

  static String? _validateUsername(String? username) {}

  static String? _validatePassword(String? password) {}

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AutofillGroup(
        child: Form(
          key: formKey,
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
                      initialValue: proxyStore.host,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Host',
                      ),
                      keyboardType: TextInputType.url,
                      autofillHints: const [AutofillHints.url],
                      validator: _validateHost,
                      onSaved: (host) => proxyStore.host = host,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    flex: 3,
                    child: TextFormField(
                      initialValue: proxyStore.port?.toString(),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Port',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: _validatePort,
                      onSaved: (port) => proxyStore.port =
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
                initialValue: proxyStore.username,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Username',
                ),
                keyboardType: TextInputType.text,
                autofillHints: const [AutofillHints.username],
                validator: _validateUsername,
                onSaved: (username) => proxyStore.username = username,
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: proxyStore.password,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
                obscureText: true,
                autofillHints: const [AutofillHints.password],
                validator: _validatePassword,
                onSaved: (password) => proxyStore.password = password,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
