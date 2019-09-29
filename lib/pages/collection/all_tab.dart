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
      onRefresh: () => CollectionModel.of(context).refresh(user),
      child: ScopedModelDescendant<CollectionModel>(
        builder: (context, child, model) {
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

          if (model.downloading) {
            return const Center(
              child: const CircularProgressIndicator(),
            );
          }

          return buildMainContent(context, model);
        },
      ),
    );
  }

  Widget buildMainContent(BuildContext context, CollectionModel model) {
    // Main content.
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: <Widget>[
        ...buildStationsDisplay(model.asyncStations(UserModel.of(context).user)),
      ],
    );
  }

  List<Widget> buildStationsDisplay(List<Station> stations) {
    void findStations() {
      print('Find stations');
    }

    // Split the station list into two lists of art urls and labels, filtering out the shuffle station
    final stationsWithoutShuffle = stations.where((station) => !station.isShuffle).toList(growable: false);
    final stationArtUrls = List<String>(stationsWithoutShuffle.length);
    final stationLabels = List<String>(stationsWithoutShuffle.length);

    for (int i = 0; i < stationsWithoutShuffle.length; i++) {
      final station = stationsWithoutShuffle[i];
      stationArtUrls[i] = station.getArtUrl(500);
      stationLabels[i] = station.title;
    }

    Station shuffleStation;
    for (Station station in stations) {
      if (station.isShuffle) {
        shuffleStation = station;
        break;
      }
    }

    return <Widget>[
      Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            Expanded(
              child: const Text(
                'My Stations',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.shuffle),
              tooltip: 'Find stations',
              onPressed: findStations,
            ),
            IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.add),
              tooltip: 'Find stations',
              onPressed: findStations,
            ),
          ],
        ),
      ),
      stations.isEmpty
          ? FlatButton(
              child: const Text('Find stations'),
              onPressed: findStations,
            )
          : ArtTileCarousel(
              artUrls: stationArtUrls,
              labels: stationLabels,
              onTap: (index) {
                print('Station tapped on $index');
              },
            ),
    ];
  }
}
