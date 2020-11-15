import 'package:flutter/material.dart';

class NothingPlayingDisplay extends StatelessWidget {
  const NothingPlayingDisplay();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const <Widget>[
          Icon(
            Icons.volume_off,
            size: 128,
            color: Colors.black26,
          ),
          SizedBox(height: 32),
          Text(
            'Nothing playing',
            textScaleFactor: 2,
            style: TextStyle(
              color: Colors.black26,
            ),
          ),
        ],
      ),
    );
  }
}
