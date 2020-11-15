import 'package:epimetheus/features/auth/ui/pages/initialization.dart';
import 'package:epimetheus/features/auth/ui/pages/login.dart';
import 'package:epimetheus/features/auth/ui/pages/splash.dart';
import 'package:epimetheus/features/collection/ui/pages/collection.dart';
import 'package:epimetheus/features/playback/ui/pages/now_playing.dart';
import 'package:epimetheus/flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Decides whether to use Wear OS or standard routes.
final routes = isWearOS ? _wearRoutes : _standardRoutes;

/// These routes are used by Sagas, and should be implemented in every
/// presentation implementation.
class RouteNames {
  static const initializing = '/';
  static const login = '/login';
  static const authenticating = '/authenticating';
  static const collection = '/collection';
  static const nowPlaying = '/now-playing';
}

/// These are mappings from route names to pages for the default UI.
Map<String, WidgetBuilder> get _standardRoutes => {
      RouteNames.initializing: (_) => const InitializationPage(),
      RouteNames.login: (_) => const LoginPage(),
      RouteNames.authenticating: (_) => const SplashPage(),
      RouteNames.collection: (_) => CollectionPage(),
      RouteNames.nowPlaying: (_) => NowPlayingPage(),
    };

/// These routes will be used instead of [_standardRoutes] on Wear OS.
Map<String, WidgetBuilder> get _wearRoutes => <String, WidgetBuilder>{
      RouteNames.initializing: (_) => const InitializationPage(),
      RouteNames.login: (_) => throw UnimplementedError(),
      RouteNames.authenticating: (_) => const SplashPage(),
      RouteNames.collection: (_) => throw UnimplementedError(),
      RouteNames.nowPlaying: (_) => throw UnimplementedError(),
    };
