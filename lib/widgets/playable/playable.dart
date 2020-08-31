import 'package:epimetheus/libepimetheus/structures/pandora_entity.dart';
import 'package:flutter/cupertino.dart';

abstract class PlayableWidget<T extends PandoraEntity> extends StatelessWidget {
  final T item;
  final VoidCallback onPlayPress;

  const PlayableWidget(this.item, {this.onPlayPress}) : super();
}
