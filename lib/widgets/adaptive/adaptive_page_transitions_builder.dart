import 'package:epimetheus/widgets/adaptive/values.dart';
import 'package:epimetheus/widgets/navigation_drawer.dart';
import 'package:flutter/material.dart';

class AdaptivePageTransitionsBuilder extends PageTransitionsBuilder {
  static const _zoom = const ZoomPageTransitionsBuilder();
  static const _openUpwards = const OpenUpwardsPageTransitionsBuilder();

  const AdaptivePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (shouldDisplayMobileLayout(context)) {
      return _zoom.buildTransitions(
        route,
        context,
        animation,
        secondaryAnimation,
        child,
      );
    } else {
      if (animation.value == 1) return child;

      final transition = _openUpwards.buildTransitions(
        route,
        context,
        animation,
        secondaryAnimation,
        child,
      );

      // TODO move inner part into custom navigator so no clipping is needed
      return transition;

      return SizedBox(
        child: ClipRect(
          clipper: _Clipper(MediaQuery.of(context).size),
          child: transition,
        ),
      );
    }
  }
}

class _Clipper extends CustomClipper<Rect> {
  final Size screenSize;
  final Rect _rect;

  _Clipper(this.screenSize)
      : _rect = Rect.fromLTRB(
          NavigationDrawer.maxWidth,
          0,
          screenSize.width,
          screenSize.height,
        );

  @override
  getClip(Size size) => _rect;

  @override
  bool shouldReclip(_Clipper oldClipper) {
    return oldClipper.screenSize != screenSize;
  }
}
