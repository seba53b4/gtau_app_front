import 'package:flutter/material.dart';
import 'package:gtau_app_front/constants/theme_constants.dart';
import 'package:gtau_app_front/models/enums/message_type.dart';

class CustomElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final MessageType? messageType;
  final double? width;
  final double? height;

  const CustomElevatedButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.messageType,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //Color? buttonBackgroundColor = backgroundColor;
    List<Color> colors = [primarySwatch[300]!, primarySwatch[100]!];
    if (backgroundColor == null) {
      switch (messageType) {
        case MessageType.success:
          colors = [primarySwatch[300]!, primarySwatch[100]!];
          break;
        case MessageType.error:
          colors = [Colors.red[400]!, Colors.red[300]!];
          break;
        case MessageType.warning:
          colors = [Colors.orange, Colors.orangeAccent];
          //buttonBackgroundColor = Colors.orange;
          break;
        case null:
          colors = [primarySwatch[300]!, primarySwatch[100]!];
      }
    } else {
      colors = [Colors.grey, Colors.grey[400]!];
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
        padding: EdgeInsets.zero,
      ),
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(28.0),
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Text(
            text,
            style: TextStyle(
              color: textColor ?? Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
