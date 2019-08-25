import 'package:flutter/material.dart';

AlertDialog noConnectionDialog(context) {
  return AlertDialog(
    title: Text('Can\'t connect to Pandora.'),
    content: Text('Are you connected to the Internet?'),
    actions: <Widget>[
      FlatButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/sign-in');
        },
        child: Text('Cancel'),
      )
    ],
  );
}
