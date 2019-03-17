import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/models/model.dart';
import 'package:epimetheus/pages/auth/auth_page.dart';
import 'package:epimetheus/pages/now_playing/now_playing_page.dart';
import 'package:epimetheus/pages/station_list/station_list_page.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:scoped_model/scoped_model.dart';

void main() => runApp(Epimetheus());

class Epimetheus extends StatefulWidget {
  @override
  _EpimetheusState createState() => _EpimetheusState();
}

class _EpimetheusState extends State<Epimetheus> with WidgetsBindingObserver {
  EpimetheusModel model;
  Color _primarySwatch = Colors.blue;

  StreamSubscription<MediaItem> _currentMediaItemSubscription;

  void startListening() {
    _currentMediaItemSubscription?.cancel();
    _currentMediaItemSubscription = AudioService.currentMediaItemStream.listen((mediaItem) async {
      if (mediaItem?.artUri != null) {
        final palette = await PaletteGenerator.fromImageProvider(
          NetworkImage(mediaItem.artUri),
        );
        setState(() {
          _primarySwatch = MaterialColor(
            palette.dominantColor.color.value,
            {
              50: palette.dominantColor.color,
              100: palette.dominantColor.color,
              200: palette.dominantColor.color,
              300: palette.dominantColor.color,
              400: palette.dominantColor.color,
              500: palette.dominantColor.color,
              600: palette.dominantColor.color,
              700: palette.dominantColor.color,
              800: palette.dominantColor.color,
              900: palette.dominantColor.color,
            },
          );
        });
      } else {
        setState(() {
          _primarySwatch = Colors.blue;
        });
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
    startListening();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: model,
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: _primarySwatch,
          buttonTheme: ButtonThemeData(
            buttonColor: Colors.blueAccent,
            textTheme: ButtonTextTheme.primary,
          ),
          pageTransitionsTheme: PageTransitionsTheme(
            builders: {
              TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.fuchsia: OpenUpwardsPageTransitionsBuilder(),
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
