import 'package:epimetheus/pages/collection/collection_page.dart';
import 'package:epimetheus/pages/now_playing/now_playing_page.dart';
import 'package:epimetheus/pages/preferences/proxy_preferences_page.dart';
import 'package:epimetheus/pages/signin/signin_page.dart';
import 'package:flutter/material.dart';

typedef RouteGeneratorWithParams = Route<dynamic> Function(Map<String, String> params);

final routes = <String, WidgetBuilder>{
  '/sign-in': (context) => SignInPage(),
  '/' + CollectionPage.pathPrefix: (context) => CollectionPage(),
  '/now-playing': (context) => NowPlayingPage(),
  '/preferences/proxy': (context) => ProxyPreferencesPage(),
};

/// In order to easily implement deep-linking from Pandora URLs later, browse and collection
/// page names should stay consistent with the web app's URLs at pandora.com.
/// Names can contain things like Pandora IDs, and are passed to the appropriate pages to extract
/// required data and build subpages with that data passed in.
Route<dynamic> generateRoute(RouteSettings settings) {
  final name = settings.name.startsWith('/') ? settings.name.substring(1) : settings.name;
  final paths = name.split('/');

  return _routeGenerators[paths[0]](settings, paths);
}

final _routeGenerators = <String, Route<dynamic> Function(RouteSettings settings, List<String> paths)>{
  CollectionPage.pathPrefix: CollectionPage.generateRoute,
};
// Half-done implementation that may come in handy for web support.
// Route<dynamic> generateRoute(RouteSettings settings) {
//   final uri = Uri.parse(settings.name);
//
//   return _getGeneratorFunction(_routeGenerators, uri.pathSegments.toList())(uri.queryParameters);
// }

// RouteGeneratorWithParams _getGeneratorFunction(Map<String, dynamic> map, List<String> pathSegments) {
//   print(map);
//   print(pathSegments);
//   if (pathSegments.length > 1) {
//     final newMap = map[pathSegments.first];
//     pathSegments.removeAt(0);
//     return _getGeneratorFunction(newMap, pathSegments);
//   }
//
//   final item = map[pathSegments.first];
//   return item is RouteGeneratorWithParams ? item : null;
// }
//
// final _routeGenerators = {
//   'collection': {
//     'artists': ,
//   }
// };
