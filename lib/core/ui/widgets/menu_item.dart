import 'package:flutter/material.dart';

class MenuItemData<T> {
  final T value;
  final IconData iconData;
  final String text;

  const MenuItemData({
    required this.value,
    required this.iconData,
    required this.text,
  });

  PopupMenuItem<T> get menuEntry => PopupMenuItem<T>(
        value: value,
        child: Row(
          children: [
            Icon(iconData),
            const SizedBox(width: 16),
            Text(
              text,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
}
