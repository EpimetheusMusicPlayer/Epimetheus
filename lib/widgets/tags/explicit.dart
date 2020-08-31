import 'package:flutter/material.dart';

class Explicit extends StatelessWidget {
  static const _color = const Color(0xFFA00000);

  const Explicit();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: const BoxDecoration(
        border: const Border.fromBorderSide(
          const BorderSide(
            color: _color,
          ),
        ),
        borderRadius: const BorderRadius.all(
          const Radius.circular(
            2,
          ),
        ),
      ),
      child: const Padding(
        padding: const EdgeInsets.only(left: 4, right: 4, top: 2, bottom: 2),
        child: const Text(
          'E',
          softWrap: false,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _color,
          ),
        ),
      ),
    );
  }
}
