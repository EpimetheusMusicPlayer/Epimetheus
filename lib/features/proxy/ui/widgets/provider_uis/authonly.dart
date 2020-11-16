import 'package:epimetheus/core/ui/widgets/preference_header.dart';
import 'package:epimetheus_nullable/mobx/proxy/proxy_store.dart';
import 'package:flutter/material.dart';

class AuthOnlyProviderUI extends StatefulWidget {
  final ProxyStore proxyStore;
  final GlobalKey<FormState> formKey;

  const AuthOnlyProviderUI({
    Key? key,
    required this.proxyStore,
    required this.formKey,
  }) : super(key: key);

  @override
  _AuthOnlyProviderUIState createState() => _AuthOnlyProviderUIState();
}

class _AuthOnlyProviderUIState extends State<AuthOnlyProviderUI> {
  late final TextEditingController _usernameController =
      TextEditingController(text: widget.proxyStore.username);
  late final TextEditingController _passwordController =
      TextEditingController(text: widget.proxyStore.password);

  String? _validateUsername(String? username) {
    if (username == null || username.isEmpty) {
      return 'Username cannot be empty.';
    }
  }

  String? _validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password cannot be empty.';
    }
  }

  @override
  Widget build(BuildContext context) {
    // if (!_credsLoaded) return const SizedBox();
    return SingleChildScrollView(
      child: AutofillGroup(
        child: Form(
          key: widget.formKey,
          child: Column(
            children: [
              PreferenceHeader(
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
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
