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
    final bool displayMobileLayout = MediaQuery.of(context).size.width < 800;

    if (displayMobileLayout) {
      return builder(
        NavigationDrawer(
          currentRouteName: ModalRoute.of(context).settings.name,
          displayMobileLayout: true,
        ),
        true,
      );
    } else {
      return Row(
        children: [
          NavigationDrawer(
            currentRouteName: ModalRoute.of(context).settings.name,
            displayMobileLayout: false,
          ),
          // const VerticalDivider(width: 1),
          Expanded(child: builder(null, false)),
        ],
      );
    }
  }
}
