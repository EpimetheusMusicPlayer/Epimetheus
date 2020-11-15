import 'package:iapetus/iapetus.dart';

class CollectedItem<I extends CollectionItem, A extends Annotation> {
  final I item;
  final A annotation;

  CollectedItem(this.item, this.annotation);
}
