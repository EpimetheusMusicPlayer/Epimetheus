import 'package:epimetheus/libepimetheus/structures/art/art_item.dart';

mixin StaticArtItem implements ArtItem {
  Map<int, String> get artUrls;

  @override
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

Map<int, String> createArtMapFromDecodedJSON(List<dynamic> input, [bool isThumbprint]) {
  if (input == null) {
    if (isThumbprint) {
      return const {
        1080: 'https://web-cdn.pandora.com/web-client-assets/images/thumbprint.274d67b7a9c52fffc206534972b02e7a.png',
      };
    }
    return {};
  }

  Map<int, String> artMap = Map<int, String>();
  for (dynamic artUrlEntry in input) {
    artMap[artUrlEntry['size']] = artUrlEntry['url'];
  }
  return artMap;
}
