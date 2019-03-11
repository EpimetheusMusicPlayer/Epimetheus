import 'package:epimetheus/dialogs/no_connection_dialog.dart';
import 'package:epimetheus/libepimetheus/stations.dart';
import 'package:epimetheus/models/model.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class StationListPage extends StatefulWidget {
  @override
  _StationListPageState createState() => _StationListPageState();
}

class _StationListPageState extends State<StationListPage> {
  Future<void> loadStations(EpimetheusModel model) {
    return getStations(model.user, true).then(
      (stations) {
        model.stations = stations;
      },
    ).catchError(
      (e) {
        showDialog(
          context: context,
          builder: noConnectionDialog(
            () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    final model = EpimetheusModel.of(context);
    if (model.stations == null) loadStations(model);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stations'),
      ),
      body: ScopedModelDescendant<EpimetheusModel>(
        builder: (context, child, model) {
          if (model.stations == null) return child;

          return ListView.builder(
            itemBuilder: (context, index) {
              return Text(model.stations[index].title);
            },
            itemCount: model.stations.length,
          );
        },
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
