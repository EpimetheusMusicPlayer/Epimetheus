import 'package:epimetheus/models/model.dart';
import 'package:epimetheus/pages/auth/auth_page.dart';
import 'package:epimetheus/pages/station_list/station_list_page.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

void main() => runApp(Epimetheus());

class Epimetheus extends StatefulWidget {
  @override
  _EpimetheusState createState() => _EpimetheusState();
}

class _EpimetheusState extends State<Epimetheus> {
  EpimetheusModel model;

  @override
  void initState() {
    super.initState();
    model = EpimetheusModel();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: model,
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
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
        },
      ),
    );
  }
}
