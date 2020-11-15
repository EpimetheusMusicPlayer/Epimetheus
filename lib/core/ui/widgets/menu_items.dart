import 'package:epimetheus/core/ui/widgets/menu_item.dart';
import 'package:flutter/material.dart';

enum CommonMenuItem { add, addSubItems, rename, delete, share }

extension CommonMenuItemExtensions on CommonMenuItem {
  static const _items = {
    CommonMenuItem.add: MenuItemData(
      value: CommonMenuItem.add,
      iconData: Icons.add_circle_outline,
      text: 'Collect',
    ),
    CommonMenuItem.addSubItems: MenuItemData(
      value: CommonMenuItem.addSubItems,
      iconData: Icons.add_to_photos_outlined,
      text: 'Collect all subitems',
    ),
    CommonMenuItem.rename: MenuItemData(
      value: CommonMenuItem.rename,
      iconData: Icons.edit_outlined,
      text: 'Rename',
    ),
    CommonMenuItem.delete: MenuItemData(
      value: CommonMenuItem.delete,
      iconData: Icons.remove_circle_outline,
      text: 'Remove from collection',
    ),
    CommonMenuItem.share: MenuItemData(
      value: CommonMenuItem.share,
      iconData: Icons.share_outlined,
      text: 'Share',
    ),
  };

  PopupMenuItem<CommonMenuItem> get menuEntry => _items[this]!.menuEntry;
}
