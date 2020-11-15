import 'package:flutter/material.dart';

class TabRefreshMessage extends StatelessWidget {
  final String message;
  final VoidCallback onRefresh;

  const TabRefreshMessage({
    required this.message,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          SizedBox(height: 8),
          OutlinedButton(
            onPressed: onRefresh,
            child: Text('Refresh'),
          ),
        ],
      ),
    );
  }
}
