import 'package:flutter/material.dart';

class ProxyInfoListTile extends StatelessWidget {
  const ProxyInfoListTile();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Icon(
                Icons.info_outline,
                color: Colors.black54,
              ),
              title: Text(
                'Most things will still use your system proxy settings. Tap here'
                ' for more info.',
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ),
          Divider(height: 0),
        ],
      ),
      onTap: () {
        showDialog<void>(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: const Text(
                'This proxy feature is designed to bypass Pandora\'s geo-blocks'
                '.\n\nPandora only enforces these blocks when doing certain'
                ' things. The geo-blocks are not enforced when media, like'
                ' audio and album art, is accessed, or when browsing music'
                ' or viewing your collection.\n\nThe proxy settings are used'
                ' only for the geo-blocked actions.',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('I understand'),
                )
              ],
            );
          },
        );
      },
    );
  }
}
