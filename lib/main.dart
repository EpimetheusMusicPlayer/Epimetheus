import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/models/collection/collection_model.dart';
import 'package:epimetheus/models/color/color_model.dart';
import 'package:epimetheus/models/user/user.dart';
import 'package:epimetheus/navigation/routing.dart';
import 'package:epimetheus/pages/authentication/authentication_page.dart';
import 'package:epimetheus/pages/signin/signin_page.dart';
import 'package:epimetheus/storage/secure_storage_manager.dart';
import 'package:epimetheus/widgets/adaptive/adaptive_page_transitions_builder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:universal_html/html.dart' show window;
import 'package:window_size/window_size.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO save and restore the path after login
  if (kIsWeb) window.history.pushState(null, '', '/');

  if (!kIsWeb && (Platform.isMacOS || Platform.isWindows)) {
    getWindowInfo().then((windowInfo) {
      setWindowFrame(Rect.fromLTWH(windowInfo.frame.left, windowInfo.frame.top, 300 * 3.0, 400 * 1.6));
      setWindowMinSize(const Size(300, 400));
    });
  }

  getPlatformSecureStorageManager().then((secureStorageManager) {
    Future.wait<String>([
      secureStorageManager.read('email'),
      secureStorageManager.read('password'),
      if (kIsWeb) secureStorageManager.read('apiHost'),
    ]).then((creds) {
      runApp(
        Epimetheus(
          email: creds[0],
          password: creds[1],
          apiHost: kIsWeb ? creds[2] : null,
        ),
      );
    });
  });
}

class Epimetheus extends StatefulWidget {
  final String email;
  final String password;
  final String apiHost;

  const Epimetheus({
    @required this.email,
    @required this.password,
    @required this.apiHost,
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
      startingPage = SignInPage(
        email: widget.email,
        password: widget.password,
        apiHost: widget.apiHost,
      );
    } else {
      startingPage = AuthenticationPage(
        email: widget.email,
        password: widget.password,
        apiHost: widget.apiHost,
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
                    TargetPlatform.android: const AdaptivePageTransitionsBuilder(),
                    TargetPlatform.iOS: const AdaptivePageTransitionsBuilder(),
                    TargetPlatform.macOS: const AdaptivePageTransitionsBuilder(),
                    TargetPlatform.linux: const AdaptivePageTransitionsBuilder(),
                    TargetPlatform.windows: const AdaptivePageTransitionsBuilder(),
                    TargetPlatform.fuchsia: const AdaptivePageTransitionsBuilder(),
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
