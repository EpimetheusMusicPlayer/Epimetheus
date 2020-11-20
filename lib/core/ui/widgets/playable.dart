import 'package:flutter/widgets.dart';

abstract class Playable<T> extends StatelessWidget {
  final T item;
  final VoidCallback? onPlayPress;

  const Playable(
    this.item, {
    this.onPlayPress,
  }) : super();
}
