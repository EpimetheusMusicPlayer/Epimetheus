import 'package:epimetheus/libepimetheus/stations.dart';
import 'package:flutter/material.dart';

class StationListTile extends StatelessWidget {
  final Station _station;

  StationListTile(this._station);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.network(
        _station.getArtUrl(130),
      ),
      title: Text(_station.title),
    );
  }
}
