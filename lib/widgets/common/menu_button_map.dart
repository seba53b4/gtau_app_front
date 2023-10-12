import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../constants/theme_constants.dart';

class MenuElevatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData? icon;
  final bool colorChangeOnPress;
  final String? text;
  final String? tooltipMessage;
  final Color? colorSelected;
  final Color? colorNotSelected;

  const MenuElevatedButton({
    Key? key,
    required this.onPressed,
    this.icon,
    this.colorChangeOnPress = false,
    this.text,
    this.tooltipMessage,
    this.colorSelected,
    this.colorNotSelected,
  }) : super(key: key);

  @override
  State<MenuElevatedButton> createState() => _State();
}

class _State extends State<MenuElevatedButton> {
  bool isSelected = false;
  Color colorSelected = lightBackground;
  Color colorNotSelected = primarySwatch[500]!;

  @override
  Widget build(BuildContext context) {
    double circleSize = kIsWeb ? 56 : 42;
    double sizeIcon = kIsWeb ? 24 : 22;

    if (widget.colorNotSelected != null) {
      colorNotSelected = widget.colorNotSelected!;
    }
    if (widget.colorSelected != null) {
      colorSelected = widget.colorSelected!;
    }
    return ElevatedButton(
      onPressed: () {
        if (widget.colorChangeOnPress) {
          setState(() {
            isSelected = !isSelected;
          });
        }
        widget.onPressed();
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(0),
        minimumSize: Size(circleSize, circleSize),
        shape: const CircleBorder(),
        foregroundColor: isSelected ? colorSelected : colorNotSelected,
        backgroundColor: isSelected ? colorNotSelected : colorSelected,
      ),
      child: widget.tooltipMessage != null
          ? Tooltip(
              message: widget.tooltipMessage,
              preferBelow: false,
              verticalOffset: 14,
              waitDuration: const Duration(seconds: 1),
              child: widget.text != null
                  ? Text(
                      widget.text!,
                    )
                  : Icon(
                      widget.icon,
                      size: sizeIcon,
                      color: isSelected ? colorSelected : colorNotSelected,
                    ),
            )
          : widget.text != null
              ? Text(
                  widget.text!,
                )
              : Icon(
                  widget.icon,
                  size: sizeIcon,
                  color: isSelected ? colorSelected : colorNotSelected,
                ),
    );
  }
}
