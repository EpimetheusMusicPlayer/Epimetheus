import 'package:epimetheus/audio/launch_helpers.dart';
import 'package:epimetheus/libepimetheus/stations.dart';
import 'package:epimetheus/models/collection/collection_model.dart';
import 'package:epimetheus/models/collection/collection_provider.dart';
import 'package:epimetheus/pages/collection/collection_page.dart';
import 'package:epimetheus/pages/collection/collection_tab.dart';
import 'package:epimetheus/widgets/playable/station.dart';
import 'package:flutter/material.dart';

class StationsTab extends CollectionTab<Station> {
  @override
  CollectionProvider<Station> getCollectionProvider(BuildContext context) {
    return CollectionModel.of(context).stationCollectionProvider;
  }

  @override
  Widget buildMainContent(BuildContext context, List<Station> stations) {
    final hasShuffle = stations[0].isShuffle;

    return ListView.separated(
      itemCount: hasShuffle ? stations.length - 1 : stations.length,
      itemBuilder: (context, realIndex) {
        final virtIndex = hasShuffle ? realIndex + 1 : realIndex;
        return StationListTile(stations[virtIndex], virtIndex);
      },
      separatorBuilder: (context, index) => StationListTile.separator,
    );
  }

  static CollectionPageFAB fab = CollectionPageFAB(
    expanded: false,
    title: 'SHUFFLE',
    tooltip: 'Shuffle stations',
    icon: Icons.shuffle,
    onPressed: (BuildContext context) {
      launchStation(context, 0);
    },
  );
}
