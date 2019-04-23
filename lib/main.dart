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

class Epimetheus extends StatefulWidget {
  @override
  _EpimetheusState createState() => _EpimetheusState();
}

class _EpimetheusState extends State<Epimetheus> with WidgetsBindingObserver {
  EpimetheusModel model;
  Color _primarySwatch = defaultPrimaryColor;
  Color _accentColor = defaultAccentColor;

  StreamSubscription<MediaItem> _currentMediaItemSubscription;

  String _currentArtUri;
  void startListening() {
    _currentMediaItemSubscription?.cancel();
    _currentMediaItemSubscription = AudioService.currentMediaItemStream.listen((mediaItem) async {
      print('New mediaItem: $mediaItem');
      if (mediaItem?.artUri == _currentArtUri) return;
      _currentArtUri = mediaItem?.artUri;
      if (mediaItem?.artUri != null) {
        final palette = await PaletteGenerator.fromImageProvider(
          NetworkImage(mediaItem.artUri),
        ).catchError((_) {
          setState(() {
            _primarySwatch = defaultPrimaryColor;
            _accentColor = defaultAccentColor;
          });
        });
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
          _accentColor = palette.lightVibrantColor?.color ?? palette.lightMutedColor?.color ?? palette.vibrantColor ?? palette.mutedColor ?? defaultAccentColor;
        });
      } else {
        setState(() {
          _primarySwatch = defaultPrimaryColor;
          _accentColor = defaultAccentColor;
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
      child: StreamBuilder<MediaItem>(
          initialData: AudioService.currentMediaItem,
          stream: AudioService.currentMediaItemStream,
          builder: (context, snapshot) {
            return MaterialApp(
              theme: ThemeData(
                primarySwatch: _primarySwatch,
                accentColor: _accentColor,
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
            );
          }),
    );
  }
}
