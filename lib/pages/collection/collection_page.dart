import 'package:epimetheus/models/user.dart';
import 'package:flutter/material.dart';

class CollectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Collection'),
      ),
      body: Text(UserModel.of(context).user.authToken),
    );
  }
}
