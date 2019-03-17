import 'package:epimetheus/models/model.dart';
import 'package:flutter/material.dart';

class DynamicAppBar extends StatelessWidget with PreferredSizeWidget {
  final String title;

  DynamicAppBar(this.title);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      color: EpimetheusModel.of(context, rebuildOnChange: true).inheritedAlbumArtColor,
      child: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
