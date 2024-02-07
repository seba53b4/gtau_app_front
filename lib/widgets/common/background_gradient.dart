import 'package:flutter/material.dart';

import '../../constants/theme_constants.dart';

class BackgroundGradient extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Decoration? decoration;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? margin;

  const BackgroundGradient({
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
      decoration: decoration ??
          BoxDecoration(
            gradient: RadialGradient(
            center: Alignment.center,      
            radius: 2.5,      
            focalRadius: 2      ,
            // begin: Alignment.center,      
            // end: Alignment.centerRight,      
            colors: [
              primarySwatch[50]!,      
              primarySwatch[900]!,      
            ],            
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
