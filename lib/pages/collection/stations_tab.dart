import 'package:cached_network_image/cached_network_image.dart';
import 'package:epimetheus/libepimetheus/stations.dart';
import 'package:epimetheus/models/collection.dart';
import 'package:epimetheus/models/user.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class StationsTab extends StatelessWidget {
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  void sortStations(List<Station> stations) {
    stations.sort((s1, s2) {
      if (s1.isShuffle) return -2;
      if (s2.isShuffle) return 2;
      if (s1.isThumbprint) return -1;
      if (s2.isThumbprint) return 1;

      return s1.title.compareTo(s2.title);
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: _refreshKey,
      onRefresh: () => CollectionModel.of(context).refreshStations(UserModel.of(context).user),
      child: ScopedModelDescendant<CollectionModel>(
        builder: (context, child, model) {
          if (model.hasErrorStations) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    'There was an error fetching your stations.',
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

          if (!model.downloadedStations) model.refreshStations(UserModel.of(context).user);

          if (!model.downloadedStations || model.downloadingStations) {
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
    final List<Station> stations = model.asyncStations(UserModel.of(context).user);
    sortStations(stations);

    return ListView.separated(
      itemCount: stations.length,
      itemBuilder: (context, index) {
        final station = stations[index];

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              CachedNetworkImage(
                height: 56,
                imageUrl: station.getArtUrl(0),
                placeholder: (context, imageUrl) => Image.asset('assets/music_note.png'),
                placeholderFadeInDuration: const Duration(milliseconds: 500),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(station.title),
              ),
            ],
          ),
        );
      },
      separatorBuilder: (context, index) {
        return Divider(
          height: 0,
          indent: 88,
        );
      },
    );
  }
}
