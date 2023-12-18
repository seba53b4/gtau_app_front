import 'package:flutter/material.dart';
import 'package:gtau_app_front/constants/theme_constants.dart';

class CustomTextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const CustomTextButton({super.key,
    required this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all(
          primarySwatch,
        ),
        overlayColor: MaterialStateProperty.resolveWith(
              (states) {
            if (states.contains(MaterialState.hovered) ||
                states.contains(MaterialState.pressed)) {
              return primarySwatch[200]?.withOpacity(0.2);
            }
            return Colors.transparent;
          },
        ),
      ),
      child: Text(text),
    );
  }
}
