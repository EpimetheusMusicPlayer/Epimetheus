import 'dart:io';

import 'package:dio/dio.dart';
import 'package:epimetheus/dialogs/dialogs.dart';
import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:epimetheus/libepimetheus/exceptions.dart';
import 'package:epimetheus/models/collection/collection_model.dart';
import 'package:epimetheus/models/user/user.dart';
import 'package:epimetheus/pages/signin/signin_page.dart';
import 'package:epimetheus/proxy/proxy_manager.dart';
import 'package:epimetheus/storage/secure_storage_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// This page authenticates with Pandora's servers and shows a loading animation. It doesn't take input from the user.

class AuthenticationPageArguments {
  final String email;
  final String password;

  const AuthenticationPageArguments({
    @required this.email,
    @required this.password,
  });
}

class AuthenticationPage extends StatefulWidget {
  final String email;
  final String password;
  final String apiHost;

  AuthenticationPage({
    this.email,
    this.password,
    this.apiHost,
  });

  @override
  _AuthenticationPageState createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  bool _authenticated = false;

  void cache(User user) {
    // Warm up the cache by downloading the profile picture in the background
    // TODO implement precaching on web
    if (!kIsWeb) DefaultCacheManager().downloadFile(user.profileImageUrl);

    // Download the collection
    CollectionModel.of(context).fetchAll(user);
  }

  void _authenticate() async {
    void navigateBackToSignInPage() {
      Navigator.of(context)
        ..pop()
        ..pushReplacement(
          MaterialPageRoute(
            builder: (context) {
              return SignInPage(
                email: widget.email,
                password: widget.password,
                apiHost: widget.apiHost,
              );
            },
          ),
        );
    }

    void showProxyErrorDialog() {
      showEpimetheusDialog(
        dialog: ProxyErrorDialog(
          context: context,
          onClickButton: () {
            navigateBackToSignInPage();
            Navigator.pushNamed(context, '/preferences/proxy');
          },
        ),
      );
    }

    void showNetworkErrorDialog() {
      showEpimetheusDialog(
        dialog: NetworkErrorDialog(
          context: context,
          buttonLabel: 'Back to sign in',
          onClickButton: navigateBackToSignInPage,
        ),
      );
    }

    try {
      // Configure and load some proxy settings
      final prefs = await SharedPreferences.getInstance();
      final isProxyEnabled = !kIsWeb && ProxyManager.isProxyEnabled(prefs);
      final proxy = isProxyEnabled ? await ProxyManager.geProxy(prefs, await getPlatformSecureStorageManager()) : null;
      if (isProxyEnabled && proxy == null) {
        if (mounted) _animationController.stop();
        showProxyErrorDialog();
      }

      // Authenticate with Pandora
      final User user = await (kIsWeb
          ? User.create(
              email: widget.email,
              password: widget.password,
              apiHost: widget.apiHost,
            )
          : User.create(
              email: widget.email,
              password: widget.password,
              proxy: proxy,
            ));

      UserModel.of(context).user = user;

      // Set the _authenticated bool to true so the app progresses after the next animation loop
      _authenticated = true;

      // Pre-cache some data
      cache(user);
    } on DioError catch (e) {
      if (mounted) _animationController.stop();

      print(e);

      if (e.error is SocketException) {
        showNetworkErrorDialog();
      } else if (e.message.contains('XMLHttpRequest')) {
        showEpimetheusDialog(
          dialog: CORSProxyErrorDialog(
            context: context,
            onClickButton: navigateBackToSignInPage,
          ),
        );
      } else if (e.error is HttpException && e.message.contains('407')) {
        showProxyErrorDialog();
      }
    } on HandshakeException {
      if (mounted) _animationController.stop();
      showEpimetheusDialog(
        dialog: GeoBlockErrorDialog(
          context: context,
          onClickButton: navigateBackToSignInPage,
        ),
      );
    } on LocationException {
      if (mounted) _animationController.stop();
      showEpimetheusDialog(
        dialog: GeoBlockErrorDialog(
          context: context,
          onClickButton: navigateBackToSignInPage,
        ),
      );
    } on SocketException catch (e, s) {
      if (mounted) _animationController.stop();
      showNetworkErrorDialog();
    } on InvalidAuthException {
      if (mounted) _animationController.stop();
      showEpimetheusDialog(
        dialog: AuthenticationErrorDialog(
          context: context,
          onClickButton: navigateBackToSignInPage,
        ),
      );
    } on InvalidRequestException catch (e) {
      if (mounted) _animationController.stop();
      if (e.errorCode == 0) {
        showEpimetheusDialog(
          dialog: AuthenticationErrorDialog(
            context: context,
            onClickButton: navigateBackToSignInPage,
          ),
        );
      }
    } on PandoraException catch (e) {
      if (mounted) _animationController.stop();
      showEpimetheusDialog(
        dialog: APIErrorDialog(
          context: context,
          onClickButton: navigateBackToSignInPage,
          exception: e,
        ),
      );
    }
  }

  void _postAuthentication() async {
    Navigator.pushReplacementNamed(context, '/collection');
    final secureStorageManager = await getPlatformSecureStorageManager();
    await Future.wait([
      secureStorageManager.write('email', widget.email),
      secureStorageManager.write('password', widget.password),
      if (kIsWeb) secureStorageManager.write('apiHost', widget.apiHost),
    ]);
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
