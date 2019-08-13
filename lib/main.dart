import 'package:epimetheus/pages/authentication/authentication_page.dart';
import 'package:epimetheus/pages/signin/signin_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() async {
  FlutterSecureStorage storage = FlutterSecureStorage();
  runApp(Epimetheus(
    email: await storage.read(key: 'email'),
    password: await storage.read(key: 'password'),
  ));
}

class Epimetheus extends StatelessWidget {
  final String email;
  final String password;

  const Epimetheus({
    this.email,
    this.password,
  });

  @override
  Widget build(BuildContext context) {
    Widget startingPage;

    if (password == null) {
      startingPage = SignInPage(email: email);
    } else {
      startingPage = AuthenticationPage(
        email: email,
        password: password,
      );
    }

    return MaterialApp(
      routes: {
        '/': (context) => startingPage,
      },
    );
  }
}
