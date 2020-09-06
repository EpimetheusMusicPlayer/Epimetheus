import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/models/collection/collection_model.dart';
import 'package:epimetheus/models/color/color_model.dart';
import 'package:epimetheus/models/user/user.dart';
import 'package:epimetheus/navigation/routing.dart';
import 'package:epimetheus/pages/authentication/authentication_page.dart';
import 'package:epimetheus/pages/signin/signin_page.dart';
import 'package:epimetheus/storage/secure_storage_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:window_size/window_size.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isMacOS || Platform.isWindows)) {
    getWindowInfo().then((windowInfo) {
      setWindowFrame(Rect.fromLTWH(windowInfo.frame.left, windowInfo.frame.top, 300 * 1.25, 400 * 1.6));
      setWindowMinSize(const Size(300, 400));
      setWindowMaxSize(const Size(600, 800));
    });
  }

  getPlatformSecureStorageManager().then((secureStorageManager) {
    Future.wait<String>([
      secureStorageManager.read('email'),
      secureStorageManager.read('password'),
    ]).then((creds) {
      runApp(
        Epimetheus(
          email: creds[0],
          password: creds[1],
        ),
      );
    });
  });
}

class Epimetheus extends StatefulWidget {
  final String email;
  final String password;

  const Epimetheus({
    @required this.email,
    @required this.password,
  });

  @override
  _EpimetheusState createState() => _EpimetheusState();
}

class _EpimetheusState extends State<Epimetheus> {
  UserModel _userModel = UserModel();
  CollectionModel _collectionModel = CollectionModel();
  ColorModel _colorModel = ColorModel();

  @override
  initState() {
    super.initState();
    _colorModel.init(_userModel);
  }

  @override
  dispose() {
    _colorModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget startingPage;

    if (widget.password == null) {
      startingPage = SignInPage(email: widget.email, password: widget.password);
    } else {
      startingPage = AuthenticationPage(
        email: widget.email,
        password: widget.password,
      );
    }

    final generatedRoutes = routes;
    generatedRoutes['/'] = (context) => startingPage;

    return AudioServiceWidget(
      child: ScopedModel<UserModel>(
        model: _userModel,
        child: ScopedModel<CollectionModel>(
          model: _collectionModel,
          child: ScopedModel<ColorModel>(
            model: _colorModel,
            child: MaterialApp(
              theme: ThemeData(
                primaryColor: const Color(0xFF332B57),
                accentColor: const Color(0xFFb700c8),
                pageTransitionsTheme: const PageTransitionsTheme(
                  builders: const {
                    TargetPlatform.android: const ZoomPageTransitionsBuilder(),
                    TargetPlatform.iOS: const ZoomPageTransitionsBuilder(),
                    TargetPlatform.macOS: const ZoomPageTransitionsBuilder(),
                    TargetPlatform.linux: const ZoomPageTransitionsBuilder(),
                    TargetPlatform.windows: const ZoomPageTransitionsBuilder(),
                    TargetPlatform.fuchsia: const ZoomPageTransitionsBuilder(),
                  },
                ),
                buttonTheme: const ButtonThemeData(
                  buttonColor: const Color(0xFF332B57),
                  textTheme: ButtonTextTheme.primary,
                ),
                visualDensity: VisualDensity.adaptivePlatformDensity,
              ),
              routes: generatedRoutes,
              onGenerateRoute: generateRoute,
            ),
          ),
        ),
      ),
    );
  }
}
