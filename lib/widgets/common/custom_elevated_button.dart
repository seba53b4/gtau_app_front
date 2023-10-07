import 'package:flutter/material.dart';
import 'package:gtau_app_front/models/enums/message_type.dart';

class CustomElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final MessageType? messageType;

  const CustomElevatedButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.messageType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color? buttonBackgroundColor = backgroundColor;
    if (backgroundColor == null) {
      switch (messageType) {
        case MessageType.success:
          buttonBackgroundColor = Colors.green;
          break;
        case MessageType.error:
          buttonBackgroundColor = Colors.red;
          break;
        case MessageType.warning:
          buttonBackgroundColor = Colors.orange;
          break;
        case null:
          buttonBackgroundColor = Colors.green;
      }
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: textColor ?? Colors.white,
        backgroundColor: backgroundColor ?? buttonBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
