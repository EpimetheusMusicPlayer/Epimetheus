import 'package:cached_network_image/cached_network_image.dart';
import 'package:epimetheus/routes.dart';
import 'package:epimetheus_nullable/mobx/auth/auth_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

class NavigationDrawerItem {
  final String name;
  final String routeName;
  final IconData iconData;

  const NavigationDrawerItem({
    required this.name,
    required this.routeName,
    required this.iconData,
  });
}

class NavigationDrawer extends StatelessWidget {
  final String currentRouteName;

  const NavigationDrawer({required this.currentRouteName});

  static const _navigationDrawItems = <NavigationDrawerItem>[
    NavigationDrawerItem(
      name: 'My Collection',
      routeName: RouteNames.collection,
      iconData: Icons.library_music,
    ),
    NavigationDrawerItem(
      name: 'Now Playing',
      routeName: RouteNames.nowPlaying,
      iconData: Icons.queue_music,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final authStore = GetIt.instance<AuthStore>();

    return Drawer(
      child: Column(
        children: <Widget>[
          Observer(
            builder: (context) {
              final listener = authStore.listener;
              if (authStore.listener == null) return const SizedBox();
              return UserAccountsDrawerHeader(
                accountName: Text(listener.webname),
                accountEmail: Text(listener.username),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(listener.profileImageUrl),
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    colorFilter:
                        ColorFilter.mode(Colors.black54, BlendMode.multiply),
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
                          Navigator.of(context)!
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
          TextButton(
            child: const Text('Sign out'),
            onPressed: authStore.logout,
          ),
        ],
      ),
    );
  }
}
