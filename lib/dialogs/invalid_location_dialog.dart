import 'package:flutter/material.dart';

AlertDialog invalidLocationDialog(context) {
  return AlertDialog(
    title: Text('You\'re outside the USA.'),
    content: Text('Use a VPN or proxy, or book a flight to use the app.'),
    actions: <Widget>[
      FlatButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/sign-in');
        },
        child: Text('Okay'),
      )
    ],
  );
}
