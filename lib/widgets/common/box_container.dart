import 'package:flutter/material.dart';

import '../../constants/theme_constants.dart';

class BoxContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Decoration? decoration;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? margin;

  const BoxContainer({
    Key? key,
    required this.child,
    this.padding,
    this.color,
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
      //color: color ?? const Color.fromRGBO(242, 242, 242, 1),
      decoration: decoration ??
          BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).primaryColor,
            border: Border.all(
              color: baseBorderColor,
              width: 2.0, // Cambia el ancho del borde aquí
            ),
            // boxShadow: const [
            //   BoxShadow(
            //     color: Color.fromRGBO(200, 217, 184, 0.5),
            //     spreadRadius: 3,
            //     blurRadius: 7,
            //     offset: Offset(0, 3),
            //   ),
            // ],
          ),
      width: width,
      height: height,
      alignment: alignment,
      margin: margin,
      child: child,
    );
  }
}
