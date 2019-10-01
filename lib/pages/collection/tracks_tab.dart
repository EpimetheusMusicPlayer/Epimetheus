import 'package:cached_network_image/cached_network_image.dart';
import 'package:epimetheus/libepimetheus/songs.dart';
import 'package:epimetheus/models/collection/collection.dart';
import 'package:epimetheus/models/collection/collection_provider.dart';
import 'package:epimetheus/pages/collection/collection_tab.dart';
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
      itemBuilder: (context, index) {
        final track = tracks[index];

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              CachedNetworkImage(
                height: 56,
                imageUrl: track.getArtUrl(500),
                placeholder: (context, imageUrl) => Image.asset(
                  'assets/music_note.png',
                  height: 56,
                ),
                placeholderFadeInDuration: const Duration(milliseconds: 500),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(track.title),
                    Text(track.artistTitle),
                    Text(track.albumTitle),
                  ],
                ),
              ),
              Text('${(track.duration / 60).floor()}:${track.duration.remainder(60).toString().padLeft(2, '0')}'),
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
