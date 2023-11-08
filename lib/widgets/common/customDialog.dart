import 'package:flutter/material.dart';

Future<void> showCustomDialog({
  required BuildContext context,
  required String title,
  required String content,
  required String acceptButtonLabel,
  required String cancelbuttonLabel,
  required VoidCallback onDisablePressed,
  required VoidCallback onEnablePressed,
}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            onPressed: onDisablePressed,
            child: Text(cancelbuttonLabel),
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: Text(acceptButtonLabel),
            onPressed: onEnablePressed,
          ),
        ],
      );
    },
  );
}
