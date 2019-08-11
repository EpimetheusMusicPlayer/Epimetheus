import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/art_constants.dart';
import 'package:epimetheus/libepimetheus/stations.dart';
import 'package:epimetheus/models/model.dart';
import 'package:epimetheus/pages/feedback/feedback_page.dart';
import 'package:epimetheus/widgets/artful_drawer_tile_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

void openFeedbackPage(BuildContext context, Station station) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (BuildContext context) => FeedbackPage(station),
    ),
  );
}

class NavigationDrawerWidget extends StatelessWidget {
  final String currentPath;

  const NavigationDrawerWidget(this.currentPath);

  @override
  Widget build(BuildContext context) {
    final model = EpimetheusModel.of(context);

    return Drawer(
      child: Column(
        children: <Widget>[
          model.user != null
              ? Stack(
                  alignment: Alignment.topRight,
                  children: <Widget>[
                    UserAccountsDrawerHeader(
                      margin: EdgeInsets.zero,
                      accountEmail: Text(model.user.email, style: const TextStyle(color: Colors.white)),
                      accountName: Text(model.user.username, style: const TextStyle(color: Colors.white)),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(model.user.profileImageUrl),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            const Color(0x8F000000),
                            BlendMode.multiply,
                          ),
                        ),
                        color: artBackgroundColor,
                      ),
                    ),
                    SafeArea(
                      child: PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert,
                          color: Colors.white,
                        ),
                        tooltip: 'More',
                        itemBuilder: (context) {
                          return const [
                            const PopupMenuItem<String>(
                              value: 'sign_out',
                              child: const Text('Sign out'),
                            )
                          ];
                        },
                        onSelected: (value) async {
                          switch (value) {
                            case 'sign_out':
                              await FlutterSecureStorage().delete(key: 'password');
                              await AudioService.stop();
                              Navigator.of(context).pushReplacementNamed('/');
                              model.stations = null;
                              break;
                          }
                        },
                      ),
                    )
                  ],
                )
              : SafeArea(
                  child: SizedBox(width: 0, height: 0),
                ),
          Divider(height: 0),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ArtfulDrawerTileWidget(
                  icon: Icons.playlist_play,
                  title: 'Now Playing',
                  routeName: '/now_playing',
                  selected: currentPath == '/now_playing',
                  foregroundColor: Colors.black,
                  backgroundBuilder: (context) {
                    final background = AudioService.currentMediaItem?.artUri != null
                        ? FadeInImage.assetNetwork(
                            placeholder: 'assets/music_note.png',
                            image: AudioService.currentMediaItem.artUri,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                          )
                        : Image.asset(
                            'assets/music_note.png',
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                          );
                    if (currentPath == '/now_playing' || AudioService.currentMediaItem?.id == null) {
                      return Opacity(
                        opacity: 0.2,
                        child: background,
                      );
                    } else {
                      return Opacity(
                        opacity: 0.2,
                        child: Hero(
                          tag: AudioService.currentMediaItem.id + '/image',
                          child: background,
                        ),
                      );
                    }
                  },
                  showBackground: true,
                ),
                ArtfulDrawerTileWidget(
                  icon: Icons.library_music,
                  title: 'My Stations',
                  routeName: '/station_list',
                  selected: currentPath == '/station_list',
                  foregroundColor: Colors.black,
                  backgroundBuilder: (context) {
                    final stations = EpimetheusModel.of(context).stations;
                    final stationArts = <Widget>[
                      SizedBox.expand(
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: const Color(0x8A000000)),
                        ),
                      ),
                    ];
                    final useHero = false; //currentPath != '/station_list'; TODO this is glitchy
                    for (int i = 0; i < stations.length; i++) {
                      final image = Image.network(
                        stations[i].getArtUrl(130),
                        height: 72,
                        fit: BoxFit.fitHeight,
                      );

                      stationArts.add(
                        Positioned(
                          left: (i * 45).toDouble(),
                          child: useHero
                              ? Hero(
                                  tag: stations[i].pandoraId + '/image',
                                  child: image,
                                )
                              : image,
                        ),
                      );
                    }
                    return Opacity(
                      opacity: 0.2,
                      child: Stack(
                        children: stationArts,
                      ),
                    );
                  },
                  showBackground: EpimetheusModel.of(context).stations != null,
                ),
              ],
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: AboutListTile(
                  icon: const Icon(Icons.info_outline),
                  applicationVersion: '0.1.0 (Alpha)',
                  applicationIcon: Image.asset(
                    'assets/app_icon.png',
                    width: 48,
                  ),
                  aboutBoxChildren: <Widget>[
                    const Text(
                      'The Epimethus app - an open source Pandora client for Android, with other platforms coming soon™.\n\nLicensed under the GPLv3 license.',
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    GestureDetector(
                      onTap: () {
                        launch(
                          'https://github.com/EpimetheusMusicPlayer/Epimetheus/issues/new',
                          enableJavaScript: true,
                        );
                      },
                      child: Text(
                        'Submit an issue or feature request',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontFamily: 'monospace',
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: IconButton(
                  icon: Icon(Icons.code),
                  onPressed: () => launch('https://github.com/EpimetheusMusicPlayer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
