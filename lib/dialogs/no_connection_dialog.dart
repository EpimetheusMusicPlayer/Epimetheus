import 'package:flutter/material.dart';

WidgetBuilder noConnectionDialog(VoidCallback onClick) => (context) {
      return AlertDialog(
        title: Text('Can\'t connect to Pandora.'),
        content: Text('Are you connected to the Internet?'),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
              onClick();
            },
            child: Text('Cancel'),
          )
        ],
      );
    };
