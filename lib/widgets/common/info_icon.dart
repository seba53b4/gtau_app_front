import 'package:flutter/material.dart';

class InfoIcon extends StatelessWidget {
  final String message;
  final VoidCallback? onPress;
  final Color iconColor;

  const InfoIcon({
    required this.message,
    this.onPress,
    this.iconColor = Colors.grey,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      child: IconButton(
        icon: Icon(
          Icons.info,
          color: iconColor,
        ),
        onPressed: onPress,
      ),
    );
  }
}
