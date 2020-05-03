import 'package:epimetheus/libepimetheus/songs.dart';
import 'package:epimetheus/models/collection/collection_model.dart';
import 'package:epimetheus/models/collection/paged_collection_provider.dart';
import 'package:epimetheus/pages/collection/paged_collection_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

class TracksTab extends PagedCollectionTab<Track> {
  @override
  PagedCollectionProvider<Track> getCollectionProvider(BuildContext context) {
    return CollectionModel.of(context).trackCollectionProvider;
  }

  @override
  Widget buildListTile(BuildContext context, int index, track) {
    return Text(
      '$index - ${track.title}',
      style: TextStyle(color: index.remainder(24) == 0 ? Theme.of(context).accentColor : null),
    );
  }
}
