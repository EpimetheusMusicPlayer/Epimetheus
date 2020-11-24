import 'package:epimetheus/features/preferences/ui/preference_header.dart';
import 'package:epimetheus_nullable/mobx/proxy/proxy_store.dart';
import 'package:flutter/material.dart';

class AuthOnlyProviderUI extends StatelessWidget {
  final ProxyStore proxyStore;
  final GlobalKey<FormState> formKey;

  const AuthOnlyProviderUI({
    Key? key,
    required this.proxyStore,
    required this.formKey,
  }) : super(key: key);

  static String? _validateUsername(String? username) {
    if (username == null || username.isEmpty) {
      return 'Username cannot be empty.';
    }
  }

  static String? _validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password cannot be empty.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AutofillGroup(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              PreferenceHeader(
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
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
