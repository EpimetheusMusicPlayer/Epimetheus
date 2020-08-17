import 'package:cached_network_image/cached_network_image.dart';
import 'package:epimetheus/models/user/user.dart';
import 'package:epimetheus/pages/signin/signin_page.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class NavigationDrawerItem {
  final String name;
  final String routeName;
  final IconData iconData;

  const NavigationDrawerItem({
    @required this.name,
    @required this.routeName,
    @required this.iconData,
  });
}

class NavigationDrawer extends StatelessWidget {
  final String currentRouteName;

  const NavigationDrawer({this.currentRouteName});

  static const _navigationDrawItems = const <NavigationDrawerItem>[
    const NavigationDrawerItem(name: 'My Collection', routeName: '/collection', iconData: Icons.library_music),
    const NavigationDrawerItem(name: 'Now Playing', routeName: '/now-playing', iconData: Icons.queue_music),
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          ScopedModelDescendant<UserModel>(
            builder: (context, child, model) {
              return UserAccountsDrawerHeader(
                accountName: Text(model.user.username),
                accountEmail: Text(model.user.email),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(model.user.profileImageUrl),
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    colorFilter: ColorFilter.mode(Colors.black54, BlendMode.multiply),
                  ),
                ),
              );
            },
          ),
          Expanded(
            child: ListTileTheme.merge(
              selectedColor: const Color(0xFF820096), // Dark accent color
              child: ListView(
                padding: EdgeInsets.zero,
                children: <ListTile>[
                  for (NavigationDrawerItem item in _navigationDrawItems)
                    ListTile(
                      leading: Icon(item.iconData),
                      title: Text(item.name),
                      selected: item.routeName == currentRouteName,
                      onTap: () {
                        if (item.routeName != currentRouteName) {
                          Navigator.of(context)
                            ..pop()
                            ..pushReplacementNamed(item.routeName);
                        }
                      },
                    )
                ],
              ),
            ),
          ),
          const Divider(height: 0),
          FlatButton(
            child: const Text('Sign out'),
            onPressed: () {
              signOut(context);
            },
          ),
        ],
      ),
    );
  }
}
