import 'package:cached_network_image/cached_network_image.dart';
import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:epimetheus/libepimetheus/stations.dart';
import 'package:epimetheus/models/collection.dart';
import 'package:epimetheus/pages/collection/collection_tab.dart';
import 'package:flutter/material.dart';

class StationsTab extends CollectionTab<List<Station>> {
  StationsTab() : super(errorMessage: 'There was an error fetching your stations.');

  @override
  Future<void> refresh(User user, CollectionModel model) => model.refreshStations(user);

  @override
  List<Station> get(User user, CollectionModel model) => model.asyncStations(user);

  @override
  bool hasError(CollectionModel model) => model.hasErrorStations;

  @override
  Widget buildMainContent(BuildContext context, List<Station> stations) {
    stations.sort((s1, s2) {
      if (s1.isShuffle) return -2;
      if (s2.isShuffle) return 2;
      if (s1.isThumbprint) return -1;
      if (s2.isThumbprint) return 1;

      return s1.title.compareTo(s2.title);
    });

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
                imageUrl: station.getArtUrl(500),
                placeholder: (context, imageUrl) => Image.asset(
                  'assets/music_note.png',
                  height: 56,
                ),
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
