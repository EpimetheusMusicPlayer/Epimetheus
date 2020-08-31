import 'package:flutter/material.dart';

// TODO is there a way to fix this warning without impacting performance?
// ignore: must_be_immutable
class MultiGradient extends StatelessWidget {
  final Color top;
  final Color center;
  final Color bottom;
  final double spread;
  final Widget child;

  final double inverseSpread;
  Color topLerp;
  Color bottomLerp;

  MultiGradient({
    Key key,
    @required Color top,
    @required Color center,
    @required Color bottom,
    this.spread = 0.2,
    final int alpha = 55, //30,
    @required this.child,
  })  : this.top = top?.withAlpha(alpha),
        this.center = center.withAlpha(alpha),
        this.bottom = bottom?.withAlpha(alpha),
        inverseSpread = 1 - spread,
        super(key: key) {
    topLerp = top == null ? this.center.withAlpha(0) : Color.lerp(this.top, this.center, 0.5);
    bottomLerp = bottom == null ? this.center.withAlpha(0) : Color.lerp(this.center, this.bottom, 0.5);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ShaderMask(
            shaderCallback: (rect) {
              return LinearGradient(
                colors: [Colors.transparent, Colors.black, Colors.transparent],
                stops: [0, 0.06, 1],
              ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
            },
            blendMode: BlendMode.dstIn,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    topLerp,
                    center,
                    center,
                    bottomLerp,
                  ],
                  stops: [0, spread, inverseSpread, 1],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
