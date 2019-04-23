import 'package:flutter/material.dart';

class AppBarTitleSubtitleWidget extends StatelessWidget {
  final String title;
  final String subtitle;

  const AppBarTitleSubtitleWidget(this.title, this.subtitle);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title),
        const SizedBox(height: 1),
        // TODO this is ugly AF
        Text(
          subtitle,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w100),
        ),
      ],
    );
  }
}
