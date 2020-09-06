import 'package:epimetheus/libepimetheus/structures/collection/entity_creator.dart';
import 'package:epimetheus/libepimetheus/structures/pandora_entity.dart';

class GenericEntityCreator extends EntityCreator<PandoraEntity> {
  const GenericEntityCreator(Map<String, dynamic> annotationsMap, List<dynamic> itemMapList) : super(annotationsMap, itemMapList);

  @override
  PandoraEntity createItem(Map<String, dynamic> annotationMap, [Map<String, dynamic> itemMap]) {
    return genericEntityCreators[PandoraEntity.types[annotationMap['type']]]?.createItem(annotationMap, itemMap);
  }
}
