import 'package:flutter/material.dart';

WidgetBuilder invalidLocationDialog = (context) {
  return AlertDialog(
    title: Text('You\'re outside the USA.'),
    content: Text(
        'Enable Portaller (a free proxy service), use another VPN/Proxy, or book a flight to use the app.'),
    actions: <Widget>[
      FlatButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text('Okay'),
      )
    ],
  );
};
