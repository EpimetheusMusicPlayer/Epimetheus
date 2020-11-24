import 'package:flutter/material.dart';

class PreferenceHeader extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry padding;

  const PreferenceHeader(
    this.text, {
    this.padding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 8,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: SizedBox(
        height: 24,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
