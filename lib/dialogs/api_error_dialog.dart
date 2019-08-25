import 'package:flutter/material.dart';

AlertDialog apiErrorDialog(context) {
  return AlertDialog(
    title: Text('An API error has occured.'),
    content: Text('Please sign in again. If this is a recurring issue, please contact the developer.'),
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
