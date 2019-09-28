import 'package:epimetheus/libepimetheus/stations.dart';
import 'package:epimetheus/models/collection.dart';
import 'package:epimetheus/models/user.dart';
import 'package:epimetheus/widgets/art_displays.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class AllTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<CollectionModel>(
      builder: (context, child, model) {
        // Gets the current downloaded station list, and if it doesn't exist, starts the download.
        final List<Station> stations = model.asyncStations(UserModel.of(context).user);

        if (model.hasError) {
          return Center(
            child: const Text(
              'There was an error fetching your stuff. Please try again.',
            ),
          );
        }

        if (stations == null) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        return buildMainContent(stations);
      },
    );
  }

  Widget buildMainContent(List<Station> stations) {
    // Split the station list into two lists of art urls and labels.
    final stationArtUrls = List<String>(stations.length);
    final stationLabels = List<String>(stations.length);

    for (int i = 0; i < stations.length; i++) {
      final station = stations[i];
      stationArtUrls[i] = station.getArtUrl(500);
      stationLabels[i] = station.title;
    }

    // Main content.
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
  }
}
