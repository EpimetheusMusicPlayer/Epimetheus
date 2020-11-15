import 'package:flutter/material.dart';

/// This page is designed to be shown when the authentication flow is starting
/// up, and data is being read from storage.
///
/// This is usually extremely fast, so an empty page provides the best
/// user experience.
class InitializationPage extends StatelessWidget {
  const InitializationPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
