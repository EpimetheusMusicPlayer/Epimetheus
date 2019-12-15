import 'package:epimetheus/libepimetheus/structures/pandora_entity.dart';

class ArtItem extends PandoraEntity {
  final Map<int, String> artUrls;

  const ArtItem(String pandoraId, this.artUrls) : super(pandoraId);

  String getArtUrl(int preferredSize) {
    if (artUrls.isNotEmpty) {
      if (artUrls.containsKey(preferredSize)) return artUrls[preferredSize];

      List<int> sortedKeys = List.from(artUrls.keys, growable: false);
      sortedKeys.sort();

      for (int size in sortedKeys) {
        if (preferredSize <= size) return artUrls[size];
      }
      return artUrls[sortedKeys.last];
    } else {
      return 'https://www.pandora.com/web-version/1.25.1/images/album_500.png';
//      return 'https://www.pandora.com/web-client-assets/images/album_640.95e90f3a2ec9c70e2b0f6b7082be38f0.png';
    }
  }
}

Map<int, String> createArtMapFromDecodedJSON(List<dynamic> input) {
  if (input == null) return {};

  Map<int, String> artMap = Map<int, String>();
  for (dynamic artUrlEntry in input) {
    artMap[artUrlEntry['size']] = artUrlEntry['url'];
  }
  return artMap;
}