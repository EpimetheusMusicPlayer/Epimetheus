import 'package:epimetheus/pages/authentication/authentication_page.dart';
import 'package:flutter/material.dart';

/// The user inputs their credentials to this page, which then passes them on to [AuthenticationPage].
/// If an email is passed in from the app launching code,it automatically fill that in.

class SignInPage extends StatelessWidget {
  final String email;

  SignInPage({this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text('Signed out!\n$email'),
    );
  }
}
