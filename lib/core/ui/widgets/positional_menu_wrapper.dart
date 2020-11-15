import 'package:flutter/material.dart';

typedef ShowMenu = Future<T?> Function<T>({
  required BuildContext context,
  required List<PopupMenuEntry<T>> items,
  T? initialValue,
  double? elevation,
  String? semanticLabel,
  ShapeBorder? shape,
  Color? color,
  bool useRootNavigator,
});

typedef MenuChildBuilder = Widget Function(
  BuildContext context,
  ValueChanged<Offset> tapDownCallback,
  ShowMenu showMenu,
  Widget? child,
);

class PositionalMenuWrapper extends StatefulWidget {
  final MenuChildBuilder builder;
  final Widget? child;

  const PositionalMenuWrapper({
    Key? key,
    required this.builder,
    this.child,
  }) : super(key: key);

  @override
  _PositionalMenuWrapperState createState() => _PositionalMenuWrapperState();
}

class _PositionalMenuWrapperState extends State<PositionalMenuWrapper> {
  Offset _menuPosition = Offset.zero;

  void _storeMenuPosition(Offset menuPosition) => _menuPosition = menuPosition;

  Future<T?> _showMenu<T>({
    required BuildContext context,
    required List<PopupMenuEntry<T>> items,
    T? initialValue,
    double? elevation,
    String? semanticLabel,
    ShapeBorder? shape,
    Color? color,
    bool useRootNavigator = false,
  }) {
    final overlay = Overlay.of(context)!.context.findRenderObject()!;
    if (overlay is RenderBox) {
      return showMenu<T>(
        context: context,
        position: RelativeRect.fromLTRB(
          _menuPosition.dx,
          _menuPosition.dy,
          overlay.size.width - _menuPosition.dx,
          overlay.size.height - _menuPosition.dy,
        ),
        items: items,
        initialValue: initialValue,
        elevation: elevation,
        semanticLabel: semanticLabel,
        shape: shape,
        color: color,
        useRootNavigator: useRootNavigator,
      );
    } else {
      return Future.error(
        'Could not calculate widget size (no RenderBox)!',
        StackTrace.current,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      _storeMenuPosition,
      _showMenu,
      widget.child,
    );
  }
}

extension PositionalMenuWrapperExtensions on TapDownDetails {
  Offset get menuOffset => globalPosition;
}
