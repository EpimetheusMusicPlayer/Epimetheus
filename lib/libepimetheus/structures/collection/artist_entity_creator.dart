import 'package:epimetheus/libepimetheus/artists.dart';
import 'package:epimetheus/libepimetheus/structures/collection/entity_creator.dart';
import 'package:epimetheus/libepimetheus/utils.dart';

class ArtistEntityCreator extends EntityCreator<Artist> {
  const ArtistEntityCreator(Map<String, dynamic> annotationsMap, List<dynamic> itemMapList) : super(annotationsMap, itemMapList);

  @override
  Artist createItem(Map<String, dynamic> annotationMap, [Map<String, dynamic> itemMap]) {
    final icon = annotationMap['icon'];
    return Artist(
      pandoraId: annotationMap['pandoraId'],
      name: annotationMap['name'],
      albumCount: annotationMap['albumCount'],
      trackCount: annotationMap['trackCount'],
      hasRadio: annotationMap['hasRadio'],
      dominantColor: pandoraColorToColor(icon['dominantColor']),
      artUrls: {
        500: 'https://content-images.p-cdn.com/${icon['artUrl']}',
      },
    );
  }
}
