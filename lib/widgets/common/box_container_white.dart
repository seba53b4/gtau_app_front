import 'package:flutter/material.dart';

import '../../constants/theme_constants.dart';

class BoxContainerWhite extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Decoration? decoration;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? margin;

  const BoxContainerWhite({
    Key? key,
    required this.child,
    this.padding,
    this.decoration,
    this.width,
    this.height,
    this.alignment,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(8),
      decoration: decoration ??
          BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: boxContainerBorder,
              width: 5.0,
            ),
          ),
      width: width,
      height: height,
      alignment: alignment,
      margin: margin,
      child: child,
    );
  }
}
