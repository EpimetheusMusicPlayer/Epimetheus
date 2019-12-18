import 'package:epimetheus/models/collection/collection.dart';
import 'package:epimetheus/models/color/ColorModel.dart';
import 'package:epimetheus/models/user/user.dart';
import 'package:epimetheus/pages/authentication/authentication_page.dart';
import 'package:epimetheus/pages/collection/collection_page.dart';
import 'package:epimetheus/pages/now_playing/now_playing_page.dart';
import 'package:epimetheus/pages/signin/signin_page.dart';
import 'package:epimetheus/widgets/audio/audio_service_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:scoped_model/scoped_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterSecureStorage storage = FlutterSecureStorage();
  runApp(
    Epimetheus(
      email: await storage.read(key: 'email'),
      password: await storage.read(key: 'password'),
    ),
  );
}

class Epimetheus extends StatefulWidget {
  final String email;
  final String password;

  const Epimetheus({
    this.email,
    this.password,
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
    _colorModel.init();
  }

  @override
  dispose() {
    _colorModel.dispose();
    super.dispose();
  }

  Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/auth':
        final AuthenticationPageArguments args = settings.arguments;
        return MaterialPageRoute(
          builder: (context) {
            return AuthenticationPage(
              email: args.email,
              password: args.password,
            );
          },
        );

      case '/sign-in':
        final AuthenticationPageArguments args = settings.arguments;
        return MaterialPageRoute(
          builder: (context) {
            return SignInPage(
              email: args?.email,
              password: args?.password,
            );
          },
        );
    }
    return null;
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

    return AudioServiceDisplay(
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
                    TargetPlatform.android: const OpenUpwardsPageTransitionsBuilder(),
                    TargetPlatform.iOS: const OpenUpwardsPageTransitionsBuilder(),
                    TargetPlatform.fuchsia: const OpenUpwardsPageTransitionsBuilder(),
                  },
                ),
                buttonTheme: const ButtonThemeData(
                  buttonColor: const Color(0xFF332B57),
                  textTheme: ButtonTextTheme.primary,
                ),
              ),
              routes: {
                '/': (context) => startingPage,
                '/collection': (context) => CollectionPage(),
                '/now-playing': (context) => NowPlayingPage(),
              },
              onGenerateRoute: generateRoute,
            ),
          ),
        ),
      ),
    );
  }
}
