import 'package:epimetheus/libepimetheus/songs.dart';
import 'package:epimetheus/models/collection/collection.dart';
import 'package:epimetheus/models/collection/collection_provider.dart';
import 'package:epimetheus/pages/collection/collection_tab.dart';
import 'package:epimetheus/widgets/playable/track.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

class TracksTab extends CollectionTab<Track> {
  @override
  CollectionProvider<Track> getCollectionProvider(BuildContext context) {
    return CollectionModel.of(context).trackCollectionProvider;
  }

  @override
  Widget buildMainContent(BuildContext context, List<Track> tracks) {
    return ListView.separated(
      itemCount: tracks.length,
      itemBuilder: (context, index) => TrackListTile(tracks[index]),
      separatorBuilder: (context, index) => TrackListTile.separator,
    );
  }
}
