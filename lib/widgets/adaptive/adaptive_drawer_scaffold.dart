import 'package:epimetheus/widgets/adaptive/values.dart';
import 'package:epimetheus/widgets/navigation_drawer.dart';
import 'package:flutter/material.dart';

typedef AdaptiveScaffoldBuilder = Scaffold Function(
  Widget drawer,
  bool displayMobileLayout,
);

class AdaptiveScaffold extends StatelessWidget {
  final AdaptiveScaffoldBuilder builder;

  const AdaptiveScaffold({@required this.builder});

  @override
  Widget build(BuildContext context) {
    final bool displayMobileLayout = shouldDisplayMobileLayout(context);

    return Row(
      children: [
        _DrawScaler(
          drawerBuilder: (context) => NavigationDrawer(
            currentRouteName: ModalRoute.of(context).settings.name,
            displayMobileLayout: false,
          ),
          displayMobileLayout: displayMobileLayout,
          duration: const Duration(milliseconds: 100),
        ),
        if (!displayMobileLayout) const VerticalDivider(width: 0),
        Expanded(
          child: builder(
            displayMobileLayout
                ? NavigationDrawer(
                    currentRouteName: ModalRoute.of(context).settings.name,
                    displayMobileLayout: true,
                  )
                : null,
            displayMobileLayout,
          ),
        ),
      ],
    );
  }
}

class _DrawScaler extends StatelessWidget {
  final WidgetBuilder drawerBuilder;
  final bool displayMobileLayout;
  final Curve curve;
  final Duration duration;

  _DrawScaler({
    @required this.drawerBuilder,
    @required this.displayMobileLayout,
    this.curve = Curves.linear,
    @required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double width = displayMobileLayout ? 0 : NavigationDrawer.getWidth(screenSize, displayMobileLayout);

    return TweenAnimationBuilder(
      tween: Tween<double>(
        begin: width,
        end: width,
      ),
      curve: curve,
      duration: duration,
      builder: (context, value, _) {
        return SizedBox(
          width: value,
          height: screenSize.height,
          child: FittedBox(
            clipBehavior: Clip.hardEdge,
            alignment: Alignment.centerLeft,
            fit: BoxFit.cover,
            child: SizedBox(
              height: screenSize.height,
              child: value == 0 ? null : drawerBuilder(context),
            ),
          ),
        );
      },
    );
  }
}
