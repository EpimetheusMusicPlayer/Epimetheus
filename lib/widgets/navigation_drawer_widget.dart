import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/art_constants.dart';
import 'package:epimetheus/models/model.dart';
import 'package:epimetheus/widgets/artful_drawer_tile_widget.dart';
import 'package:flutter/material.dart';

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
              ? UserAccountsDrawerHeader(
                  margin: EdgeInsets.zero,
                  accountEmail: Text(model.user.email, style: TextStyle(color: Colors.white)),
                  accountName: Text(model.user.username, style: TextStyle(color: Colors.white)),
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
                    final stationArts = List<Positioned>();
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
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('About'),
            selected: currentPath == '/about',
            onTap: () {
              final navigator = Navigator.of(context);
              navigator.pop();
              navigator.pushReplacementNamed('/about');
            },
          ),
        ],
      ),
    );
  }
}
