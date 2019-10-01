import 'package:epimetheus/libepimetheus/stations.dart';
import 'package:epimetheus/models/collection/collection.dart';
import 'package:epimetheus/models/collection/collection_provider.dart';
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
    return ListView.separated(
      itemCount: stations.length,
      itemBuilder: (context, index) => StationListTile(stations[index], index),
      separatorBuilder: (context, index) => StationListTile.separator,
    );
  }
}
