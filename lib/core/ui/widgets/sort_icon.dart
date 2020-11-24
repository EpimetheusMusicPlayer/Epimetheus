import 'package:flutter/material.dart';

/// An icon that represents the current sorting setting, made mainly for
/// buttons.
class SortIcon extends StatelessWidget {
  /// An icon representing the sort order in use.
  final Icon sortOrderIcon;

  const SortIcon({
    Key? key,
    required this.sortOrderIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 12,
          top: 12,
          child: const Icon(
            Icons.sort_rounded,
            color: Colors.white,
          ),
        ),
        Positioned(
          right: 12,
          bottom: 12,
          child: IconTheme(
            data: IconTheme.of(context).copyWith(
              size: 18,
              color: Colors.white70,
            ),
            child: sortOrderIcon,
          ),
        ),
      ],
    );
  }
}
