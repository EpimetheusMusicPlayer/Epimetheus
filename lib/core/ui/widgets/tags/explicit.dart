import 'package:flutter/material.dart';

class Explicit extends StatelessWidget {
  static const _color = Color(0xFFA00000);

  const Explicit();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        border: Border.fromBorderSide(
          BorderSide(
            color: _color,
          ),
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(
            2,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 4, right: 4, top: 2, bottom: 2),
        child: Text(
          'E',
          softWrap: false,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _color,
          ),
        ),
      ),
    );
  }
}
