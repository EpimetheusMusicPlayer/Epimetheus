import 'package:flutter/material.dart';

class ListFooterMessage extends StatelessWidget {
  final String message;

  const ListFooterMessage(
    this.message, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}
