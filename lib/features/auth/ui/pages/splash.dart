import 'package:flutter/material.dart';

/// A page to be shown during login.
/// Supports Wear OS.
class SplashPage extends StatefulWidget {
  static const _animationDuration = Duration(seconds: 1);
  static const _animationCurve = Curves.easeInOut;

  const SplashPage();

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: SplashPage._animationDuration,
    lowerBound: 0.75,
  );
  late final _progress =
      CurveTween(curve: SplashPage._animationCurve).animate(_controller);

  @override
  void initState() {
    super.initState();
    // Start the animation controller
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _progress,
          builder: (context, child) {
            return SizedBox(
              width: _progress.value * MediaQuery.of(context).size.width / 2.75,
              child: child,
            );
          },
          child: Hero(
            tag: 'app_icon',
            child: Image.asset(
              'assets/app_icon.png',
            ),
          ),
        ),
      ),
    );
  }
}
