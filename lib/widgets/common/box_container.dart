import 'package:flutter/material.dart';

import '../../constants/theme_constants.dart';

class BoxContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Decoration? decoration;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? margin;

  const BoxContainer({
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
            borderRadius: BorderRadius.circular(20),
            gradient: RadialGradient(
              // center: Alignment.center,
              radius: 2.5,
              focalRadius: 2,
              colors: [
                dashboardBackground,
                dashboardBackground,
              ],
            ),
            border: Border.all(
              color: lightBackground,
              width: 4.0,
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
