import 'package:flutter/material.dart';
import 'package:prompt_dialog/prompt_dialog.dart';

void handleRename({
  required BuildContext context,
  required String oldName,
  required Future<String?> Function(String name) rename,
}) async {
  // ignore: unnecessary_cast
  final name = await prompt(
    context,
    title: Text('Rename "$oldName"'),
    textOK: Text('Okay'),
    initialValue: oldName,
    autoFocus: true,
  ) as String?;

  if (name == null || name == oldName || name.isEmpty) return;

  final scaffoldMessenger = ScaffoldMessenger.of(context);
  scaffoldMessenger.hideCurrentSnackBar();

  scaffoldMessenger.showSnackBar(
    SnackBar(
      content: Text('Renaming "$oldName" to "$name"...'),
    ),
  );

  final errorMessage = await rename(name);
  scaffoldMessenger.hideCurrentSnackBar();
  if (errorMessage != null) {
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text('Could not rename "$oldName": $errorMessage'),
      ),
    );
  }
}
