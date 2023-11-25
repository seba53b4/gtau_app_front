import 'package:flutter/foundation.dart';
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
      return ScaleTransition(
        scale: CurvedAnimation(
          parent: ModalRoute.of(context)!.animation!,
          curve: Curves.easeInOut,
        ),
        child: AlertDialog(
          title: Container(
            alignment: Alignment.center,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: kIsWeb ? 28 : 22,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Divider(
                height: 8,
                thickness: 2,
                color: Colors.grey.shade100,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
                child: Center(
                  child: Text(
                    content,
                    style: const TextStyle(fontSize: kIsWeb ? 16 : 14),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Divider(
                height: 8,
                thickness: 2,
                color: Colors.grey.shade100,
              ),
            ],
          ),
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
              onPressed: onEnablePressed,
              child: Text(acceptButtonLabel),
            ),
          ],
        ),
      );
    },
  );
}
