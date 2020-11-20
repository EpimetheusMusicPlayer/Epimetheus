import 'package:flutter/material.dart';
import 'package:iapetus/iapetus.dart';

class LyricCard extends StatelessWidget {
  final LyricSnippet lyricSnippet;
  final bool isDominantColorDark;
  final Color foregroundColor;

  const LyricCard({
    Key? key,
    required this.lyricSnippet,
    required this.isDominantColorDark,
    required this.foregroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      color: foregroundColor.withAlpha(230),
      height: 1.5,
    );

    final lines = [...lyricSnippet.lines, '\u2026'];
    final backgroundColor = Colors.white.withAlpha(30);

    return Card(
      color: backgroundColor,
      shadowColor: backgroundColor,
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: lines.length,
          itemBuilder: (context, index) {
            return Text(
              lines[index],
              style: textStyle,
              textAlign: TextAlign.center,
              textScaleFactor: 1.1,
              // maxLines: 1,
              // softWrap: false,
              overflow: TextOverflow.fade,
            );
          },
        ),
      ),
    );
  }
}
