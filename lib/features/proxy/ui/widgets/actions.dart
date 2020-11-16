import 'package:epimetheus/routes.dart';
import 'package:flutter/material.dart';

class ProxyPreferencesAction extends StatelessWidget {
  const ProxyPreferencesAction();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.vpn_lock_outlined),
      onPressed: () {
        Navigator.of(context)!.pushNamed(RouteNames.proxyPreferences);
      },
    );
  }
}
