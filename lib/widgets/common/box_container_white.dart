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
  final bool withBorder;

  const BoxContainerWhite({
    Key? key,
    required this.child,
    this.padding,
    this.decoration,
    this.width,
    this.height,
    this.alignment,
    this.margin,
    this.withBorder = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(8),
      decoration: decoration ??
          BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: withBorder
                ? Border.all(
                    color: primarySwatch[900]!,
                    width: 2.0,
                  )
                : Border.all(
                    color: Colors.transparent,
                    width: 1.0,
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
