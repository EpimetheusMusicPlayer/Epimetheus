import 'package:epimetheus/art_constants.dart';
import 'package:epimetheus/models/model.dart';
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
                  accountEmail: Text(model.user.email, style: TextStyle(color: Colors.white)),
                  accountName: Text(model.user.username, style: TextStyle(color: Colors.white)),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(model.user.profileImageUrl),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        const Color(0x88000000),
                        BlendMode.multiply,
                      ),
                    ),
                    color: artBackgroundColor,
                  ),
                )
              : SafeArea(
                  child: SizedBox(width: 0, height: 0),
                ),
          Expanded(
            child: ListTileTheme(
              selectedColor: Colors.blue,
              style: ListTileStyle.drawer,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: Icon(Icons.playlist_play),
                    title: Text('Now Playing'),
                    selected: currentPath == '/now_playing',
                    onTap: () {
                      final navigator = Navigator.of(context);
                      navigator.pop();
                      navigator.pushReplacementNamed('/now_playing');
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.library_music),
                    title: Text('My Stations'),
                    selected: currentPath == '/station_list',
                    onTap: () {
                      final navigator = Navigator.of(context);
                      navigator.pop();
                      navigator.pushReplacementNamed('/station_list');
                    },
                  ),
                ],
              ),
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
