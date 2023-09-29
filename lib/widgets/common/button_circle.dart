import 'package:flutter/material.dart';

class ButtonCircle extends StatefulWidget {
  final IconData icon;
  final double size;
  final VoidCallback onPressed;

  const ButtonCircle(
      {Key? key, required this.icon, required this.onPressed, required this.size})
      : super(key: key);

  @override
  State<ButtonCircle> createState() => _ButtonCircleState();
}

class _ButtonCircleState extends State<ButtonCircle> {
  bool isHovered = false;

  void _handleHover(bool hover) {
    setState(() {
      isHovered = hover;
    });
  }

  @override
  Widget build(BuildContext context) {
    final circleColor = isHovered
        ? const Color.fromRGBO(253, 255, 252, 0.45)
        : const Color.fromRGBO(96, 166, 27, 1);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: widget.size,
      width: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: circleColor,
      ),
      child: InkWell(
        onTap: () {
          widget.onPressed();
        },
        onHover: _handleHover,
        child: Icon(
          widget.icon,
          size: 28,
          color: const Color.fromRGBO(14, 45, 9, 1),
        ),
      ),
    );
  }
}
