import 'package:cached_network_image/cached_network_image.dart';
import 'package:epimetheus/libepimetheus/stations.dart';
import 'package:epimetheus/models/collection/collection.dart';
import 'package:epimetheus/models/collection/collection_provider.dart';
import 'package:epimetheus/pages/collection/collection_tab.dart';
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
