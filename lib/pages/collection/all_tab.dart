import 'dart:io';

import 'package:epimetheus/libepimetheus/exceptions.dart';
import 'package:epimetheus/libepimetheus/stations.dart';
import 'package:epimetheus/models/collection.dart';
import 'package:epimetheus/models/user.dart';
import 'package:epimetheus/widgets/art_displays.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AllTab extends StatefulWidget {
  @override
  _AllTabState createState() => _AllTabState();
}

class _AllTabState extends State<AllTab> with AutomaticKeepAliveClientMixin<AllTab> {
  @override
  bool get wantKeepAlive => true;

  List<Station> _stations;

  Future<bool> _loadData() async {
    try {
      _stations = await CollectionModel.of(context).getStations(UserModel.of(context).user);
      return true;
    } on SocketException {
      return false;
    } on PandoraException {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<bool>(
      future: _loadData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          if (snapshot.data) {
            final stationArtUrls = List<String>(_stations.length);
            final stationLabels = List<String>(_stations.length);

            for (int i = 0; i < _stations.length; i++) {
              final station = _stations[i];
              stationArtUrls[i] = station.getArtUrl(500);
              stationLabels[i] = station.title;
            }

            return ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: const Text(
                    'My Stations',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
                ArtTileCarousel(
                  artUrls: stationArtUrls,
                  labels: stationLabels,
                  onTap: (index) {
                    print('Station tapped on $index');
                  },
                ),
              ],
            );
          } else {
            return Center(
              child: const Text(
                'There was an error fetching your stuff. Please try again.',
              ),
            );
          }
        }
      },
    );
  }
}
