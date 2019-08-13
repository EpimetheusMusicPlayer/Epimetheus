import 'package:flutter/material.dart';

/// This page authenticates with Pandora's servers and shows a loading animation. It doesn't take input from the user.

class AuthenticationPage extends StatelessWidget {
  final String email;
  final String password;

  const AuthenticationPage({
    this.email,
    this.password,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text('$email\n$password'),
    );
  }
}
