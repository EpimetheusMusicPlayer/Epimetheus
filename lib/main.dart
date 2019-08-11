import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/models/model.dart';
import 'package:epimetheus/pages/auth/auth_page.dart';
import 'package:epimetheus/pages/now_playing/now_playing_page.dart';
import 'package:epimetheus/pages/station_list/station_list_page.dart';
import 'package:epimetheus/theme_constants.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:scoped_model/scoped_model.dart';

void main() {
  runApp(Epimetheus());
}

final StreamController<PaletteGenerator> _paletteStreamController =
    StreamController.broadcast();
Stream<PaletteGenerator> get paletteStream => _paletteStreamController.stream;

PaletteGenerator _palette;
PaletteGenerator get palette => _palette;

class Epimetheus extends StatefulWidget {
  @override
  _EpimetheusState createState() => _EpimetheusState();
}

class _EpimetheusState extends State<Epimetheus> with WidgetsBindingObserver {
  EpimetheusModel model;

  StreamSubscription<MediaItem> _currentMediaItemSubscription;

  String _currentArtUri;

  void startListening() {
    _currentMediaItemSubscription?.cancel();
    _currentMediaItemSubscription =
        AudioService.currentMediaItemStream.listen((mediaItem) async {
      if (mediaItem?.artUri != _currentArtUri) {
        _currentArtUri = mediaItem?.artUri;
        if (mediaItem == null) model.currentMusicProvider = null;
        if (mediaItem?.artUri == null) {
          _palette = null;
          _paletteStreamController.add(null);
        } else {
          try {
            _palette = await PaletteGenerator.fromImageProvider(
                NetworkImage(mediaItem.artUri));
            _paletteStreamController.add(palette);
          } catch (error) {
            _palette = null;
            _paletteStreamController.add(null);
          }
        }
      }
    });
  }

  void stopListening() {
    _currentMediaItemSubscription?.cancel();
    _currentMediaItemSubscription = null;
  }

  @override
  void initState() {
    super.initState();
    model = EpimetheusModel();
    AudioService.connect().then((value) {
      startListening();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        AudioService.connect();
        startListening();
        break;
      case AppLifecycleState.paused:
        stopListening();
        AudioService.disconnect();
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    stopListening();
    AudioService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: model,
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: defaultPrimaryColor,
          accentColor: defaultAccentColor,
          buttonTheme: ButtonThemeData(
            buttonColor: defaultAccentColor,
            textTheme: ButtonTextTheme.primary,
          ),
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: const {
              TargetPlatform.android: const OpenUpwardsPageTransitionsBuilder(),
              TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
              TargetPlatform.fuchsia: const OpenUpwardsPageTransitionsBuilder(),
            },
          ),
        ),
        title: 'Epimetheus',
        routes: {
          '/': (context) => AuthPage(),
          '/station_list': (context) => StationListPage(),
          '/now_playing': (context) => NowPlayingPage(),
        },
      ),
    );
  }
}

class EpimetheusThemedPage extends StatefulWidget {
  final Widget child;

  const EpimetheusThemedPage({
    @required this.child,
  });

  @override
  _EpimetheusThemedPageState createState() => _EpimetheusThemedPageState();
}

class _EpimetheusThemedPageState extends State<EpimetheusThemedPage>
    with WidgetsBindingObserver {
  static Color _primaryColor = defaultPrimaryColor;
  static Color _accentColor = defaultAccentColor;

  StreamSubscription<PaletteGenerator> _subscription;

  @override
  void initState() {
    super.initState();
    startListening();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        startListening();
        break;
      case AppLifecycleState.paused:
        stopListening();
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }

  void startListening() {
    _subscription?.cancel();
    _subscription = _paletteStreamController.stream.listen((palette) {
      if (palette == null) {
        setState(() {
          _primaryColor = defaultPrimaryColor;
          _accentColor = defaultAccentColor;
        });
      } else {
        final primaryColor = palette.dominantColor?.color ?? Colors.grey;
        final primaryColorSwatch = MaterialColor(
          primaryColor.value,
          {
            50: primaryColor,
            100: primaryColor,
            200: primaryColor,
            300: primaryColor,
            400: primaryColor,
            500: primaryColor,
            600: primaryColor,
            700: primaryColor,
            800: primaryColor,
            900: primaryColor,
          },
        );
        final accentColor =
            (palette.lightVibrantColor?.color?.value != _primaryColor.value
                    ? palette.lightVibrantColor?.color
                    : null) ??
                (palette.lightMutedColor?.color?.value != _primaryColor.value
                    ? palette.lightMutedColor?.color
                    : null) ??
                (palette.vibrantColor?.color?.value != _primaryColor.value
                    ? palette.vibrantColor?.color
                    : null) ??
                (palette.mutedColor?.color?.value != _primaryColor.value
                    ? palette.mutedColor?.color
                    : null) ??
                defaultAccentColor;
        setState(() {
          _primaryColor = primaryColorSwatch;
          _accentColor = accentColor;
        });
      }
    });
  }

  void stopListening() {
    _subscription.cancel();
    _subscription = null;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedTheme(
      data: ThemeData(
        primarySwatch: _primaryColor,
        accentColor: _accentColor,
        buttonTheme: ButtonThemeData(
          buttonColor: _accentColor,
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      child: widget.child,
    );
  }
}
