import 'dart:ui';

Color pandoraColorToColor(String pandoraColor) => pandoraColor != null ? Color(int.parse('ff' + pandoraColor, radix: 16)) : null;
