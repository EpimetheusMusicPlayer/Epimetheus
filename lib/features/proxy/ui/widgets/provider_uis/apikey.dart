import 'package:epimetheus/core/ui/widgets/preference_header.dart';
import 'package:epimetheus_nullable/mobx/proxy/proxy_store.dart';
import 'package:flutter/material.dart';

class ApiKeyProviderUI extends StatelessWidget {
  final ProxyStore proxyStore;
  final GlobalKey<FormState> formKey;

  const ApiKeyProviderUI({
    Key? key,
    required this.proxyStore,
    required this.formKey,
  }) : super(key: key);

  static String? _validateApiKey(String? apiKey) {
    if (apiKey == null || apiKey.isEmpty) {
      return 'API key cannot be empty.';
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
                'API details',
                padding: EdgeInsets.only(bottom: 4),
              ),
              TextFormField(
                initialValue: proxyStore.username,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'API key',
                ),
                keyboardType: TextInputType.text,
                autofillHints: const [AutofillHints.password],
                validator: _validateApiKey,
                onSaved: (username) => proxyStore.username = username,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
