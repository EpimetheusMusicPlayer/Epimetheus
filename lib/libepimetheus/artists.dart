import 'package:epimetheus/libepimetheus/art_item.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

class Artist extends ArtItem {
  final String title;
  final String detailUrl;

  const Artist._internal({
    @required String pandoraId,
    @required this.title,
    @required this.detailUrl,
    @required Map<int, String> artUrls,
  }) : super(pandoraId, artUrls);

  Artist(Map<String, dynamic> artistJSON)
      : this._internal(
          pandoraId: artistJSON['pandoraId'],
          title: artistJSON['name'],
          detailUrl: artistJSON['detailUrl'],
          artUrls: createArtMapFromDecodedJSON(artistJSON['art']),
        );
}
