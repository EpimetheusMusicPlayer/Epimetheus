import 'package:epimetheus/libepimetheus/stations.dart';
import 'package:epimetheus/models/collection.dart';
import 'package:epimetheus/models/user.dart';
import 'package:epimetheus/widgets/art_displays.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class AllTab extends StatelessWidget {
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    final user = UserModel.of(context).user;

    return RefreshIndicator(
      key: _refreshKey,
      onRefresh: () => CollectionModel.of(context).refreshStations(user),
      child: ScopedModelDescendant<CollectionModel>(
        builder: (context, child, model) {
          // Gets the current downloaded station list, and if it doesn't exist, starts the download.
          final List<Station> stations = model.hasError ? null : model.asyncStations(user);

          if (model.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    'There was an error fetching your collection.',
                    textAlign: TextAlign.center,
                  ),
                  FlatButton(
                    child: const Text('Try again'),
                    onPressed: _refreshKey.currentState.show,
                  ),
                ],
              ),
            );
          }

          if (stations == null) {
            return const Center(
              child: const CircularProgressIndicator(),
            );
          }

          return buildMainContent(stations, () => model.refreshStations(user));
        },
      ),
    );
  }

  Widget buildMainContent(List<Station> stations, RefreshCallback onRefresh) {
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
      physics: const AlwaysScrollableScrollPhysics(),
      children: <Widget>[
        const Padding(
          padding: const EdgeInsets.all(16),
          child: const Text(
            'My Stations',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
        stations.isEmpty
            ? FlatButton(
                child: const Text('Find stations'),
                onPressed: () {
                  print('Find stations');
                },
              )
            : ArtTileCarousel(
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
