import 'package:flutter/widgets.dart';
import 'package:iapetus/iapetus.dart';

abstract class Playable<T extends PandoraEntity> extends StatelessWidget {
  final T item;
  final VoidCallback? onPlayPress;

  const Playable(
    this.item, {
    this.onPlayPress,
  }) : super();
}
