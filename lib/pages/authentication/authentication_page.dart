import 'dart:io';

import 'package:epimetheus/dialogs/api_error_dialog.dart';
import 'package:epimetheus/dialogs/invalid_credentials_dialog.dart';
import 'package:epimetheus/dialogs/invalid_location_dialog.dart';
import 'package:epimetheus/dialogs/no_connection_dialog.dart';
import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:epimetheus/libepimetheus/exceptions.dart';
import 'package:epimetheus/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// This page authenticates with Pandora's servers and shows a loading animation. It doesn't take input from the user.

class AuthenticationPageArguments {
  final String email;
  final String password;

  AuthenticationPageArguments({
    @required this.email,
    @required this.password,
  });
}

class AuthenticationPage extends StatefulWidget {
  final String email;
  final String password;

  AuthenticationPage({
    this.email,
    this.password,
  });

  @override
  _AuthenticationPageState createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  bool _authenticated = false;

  void _authenticate() async {
    try {
      UserModel.of(context).user = (await User.create(widget.email, widget.password));
      _authenticated = true;
    } on HandshakeException {
      _animationController.stop();
      showDialog(context: context, builder: invalidLocationDialog);
    } on LocationException {
      _animationController.stop();
      showDialog(context: context, builder: invalidLocationDialog);
    } on SocketException {
      _animationController.stop();
      showDialog(context: context, builder: noConnectionDialog);
    } on InvalidRequestException catch (e) {
      _animationController.stop();
      if (e.errorCode == 0) {
        showDialog(context: context, builder: invalidCredentialsDialog);
      }
    } on PandoraException {
      _animationController.stop();
      showDialog(context: context, builder: apiErrorDialog);
    }
  }

  void _postAuthentication() {
    Navigator.pushReplacementNamed(context, '/collection');
    FlutterSecureStorage()..write(key: 'email', value: widget.email)..write(key: 'password', value: widget.password);
  }

  void _initializeAnimationController() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )
      ..addStatusListener((status) {
        switch (status) {
          case AnimationStatus.completed:
            if (_authenticated)
              setState(() {
                _animationController.duration = const Duration(milliseconds: 250);
              });
            _animationController.reverse();
            break;
          case AnimationStatus.dismissed:
            if (_authenticated) {
              _postAuthentication();
            } else
              _animationController.forward();
            break;
          default:
            break;
        }
      })
      ..forward();
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimationController();
    _authenticate();
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Hero(
          tag: 'app_icon',
          child: _LoadingWidget(
            controller: _animationController,
            begin: _authenticated ? 0.0 : 0.75,
          ),
        ),
      ),
    );
  }
}

class _LoadingWidget extends AnimatedWidget {
  final double begin;

  Animation<double> get _progress => listenable;

  const _LoadingWidget({Key key, AnimationController controller, this.begin}) : super(key: key, listenable: controller);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/app_icon.png',
      width: 156 * _progress.drive(CurveTween(curve: Curves.easeInOut)).drive(Tween(begin: begin, end: 1.0)).value,
    );
  }
}
