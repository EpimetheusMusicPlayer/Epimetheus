import 'package:flutter/material.dart';

class Explicit extends StatelessWidget {
  const Explicit();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: const BoxDecoration(
        border: const Border.fromBorderSide(
          const BorderSide(
            color: Colors.red,
          ),
        ),
        borderRadius: const BorderRadius.all(
          const Radius.circular(
            2,
          ),
        ),
      ),
      child: const Padding(
        padding: const EdgeInsets.only(left: 4, right: 4, top: 2),
        child: const Text(
          'E',
          softWrap: false,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}
