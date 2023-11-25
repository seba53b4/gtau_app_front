import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtau_app_front/constants/theme_constants.dart';

enum DialogMessageType {
  success,
  error,
  warning,
}

extension DialogMessageTypeExtension on DialogMessageType {
  String get value {
    switch (this) {
      case DialogMessageType.success:
        return 'Acción Satisfactoria';
      case DialogMessageType.error:
        return 'Error';
      case DialogMessageType.warning:
        return 'Advertencia';
    }
  }
}

class MessageDialog extends StatefulWidget {
  final DialogMessageType messageType;
  final VoidCallback onAcceptPressed;

  const MessageDialog({
    required this.messageType,
    required this.onAcceptPressed,
  });

  @override
  _MessageDialogState createState() => _MessageDialogState();
}

class _MessageDialogState extends State<MessageDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color iconColor;
    String textContent;

    switch (widget.messageType) {
      case DialogMessageType.success:
        iconData = Icons.check_circle;
        iconColor = primarySwatch;
        textContent = DialogMessageType.success.value;
        break;
      case DialogMessageType.error:
        iconData = Icons.error;
        iconColor = Colors.red;
        textContent = DialogMessageType.error.value;
        break;
      case DialogMessageType.warning:
        iconData = Icons.warning;
        iconColor = Colors.orange;
        textContent = DialogMessageType.warning.value;
        break;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              textContent,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Divider(
              height: 8,
              thickness: 2,
              color: Colors.grey.shade100,
            ),
            const SizedBox(height: 12),
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Icon(iconData, color: iconColor, size: 62),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        Divider(
          height: 8,
          thickness: 2,
          color: Colors.grey.shade100,
        ),
        const SizedBox(height: 8),
        TextButton(
          style: TextButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
          onPressed: () {
            Navigator.of(context).pop();
            widget.onAcceptPressed();
          },
          child: Text(AppLocalizations.of(context)!.dialogCloseButton),
        ),
        // CustomElevatedButton(
        //   width: 60,
        //   height: 60,
        //   text: AppLocalizations.of(context)!.dialogCloseButton,
        //   onPressed: () {
        //     Navigator.of(context).pop();
        //     widget.onAcceptPressed();
        //   },
        // ),
      ],
    );
  }
}

Future<void> showCustomMessageDialog({
  required BuildContext context,
  required DialogMessageType messageType,
  required VoidCallback onAcceptPressed,
}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: MessageDialog(
          messageType: messageType,
          onAcceptPressed: onAcceptPressed,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
      );
    },
  );
}
