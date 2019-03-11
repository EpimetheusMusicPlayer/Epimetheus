import 'package:epimetheus/libepimetheus/art_item.dart';
import 'package:meta/meta.dart';

class Artist extends ArtItem {
  final String pandoraId;
  final String title;
  final String detailUrl;

  Artist._internal({
    @required this.pandoraId,
    @required this.title,
    @required this.detailUrl,
    @required Map<int, String> artUrls,
  }) : super(artUrls);

  factory Artist(Map<String, dynamic> artistJSON) {
    return Artist._internal(
      pandoraId: artistJSON['pandoraId'],
      title: artistJSON['name'],
      detailUrl: artistJSON['detailUrl'],
      artUrls: createArtMapFromDecodedJSON(artistJSON['art']),
    );
  }
}
