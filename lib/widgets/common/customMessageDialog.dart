import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtau_app_front/constants/theme_constants.dart';

import 'custom_text_button.dart';

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
  final String customText;

  const MessageDialog({
    required this.messageType,
    required this.onAcceptPressed,
    this.customText = '',
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
      duration: const Duration(milliseconds: 300),
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

    switch (widget.messageType) {
      case DialogMessageType.success:
        iconData = Icons.check_circle;
        iconColor = primarySwatch;
        break;
      case DialogMessageType.error:
        iconData = Icons.error;
        iconColor = Colors.red;
        break;
      case DialogMessageType.warning:
        iconData = Icons.warning;
        iconColor = Colors.orange;
        break;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(
          height: 8,
          thickness: 2,
          color: Colors.grey.shade100,
        ),
        const SizedBox(height: 8),
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
        if (widget.customText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.customText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w200,
              ),
            ),
          ),
        const SizedBox(height: 12),
        Divider(
          height: 8,
          thickness: 2,
          color: Colors.grey.shade100,
        ),
        const SizedBox(height: 8),
        CustomTextButton(
          onPressed: () {
            Navigator.of(context).pop();
            widget.onAcceptPressed();
          },
          text: AppLocalizations.of(context)!.dialogCloseButton,
        ),
      ],
    );
  }
}

Future<void> showCustomMessageDialog({
  required BuildContext context,
  required DialogMessageType messageType,
  required VoidCallback onAcceptPressed,
  String customText = '',
}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        surfaceTintColor: lightBackground,
        backgroundColor: lightBackground,
        title: Center(
            child: Text(
          messageType.value,
          style: const TextStyle(
              fontSize: kIsWeb ? 24 : 20, fontWeight: FontWeight.w200),
        )),
        content: MessageDialog(
          messageType: messageType,
          onAcceptPressed: onAcceptPressed,
          customText: customText,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
      );
    },
  );
}
