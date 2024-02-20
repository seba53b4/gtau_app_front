import 'package:flutter/material.dart';
import 'package:gtau_app_front/constants/theme_constants.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingWidget extends StatelessWidget {
  final double? widthRatio;
  final double? heightRatio;

  const LoadingWidget({super.key, this.widthRatio, this.heightRatio});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: widthRatio != null ? screenWidth * widthRatio! : screenWidth,
      height: heightRatio != null ? screenHeight * heightRatio! : screenHeight,
      child: Center(
          child: LoadingAnimationWidget.discreteCircle(
        color: primarySwatch[400]!,
        secondRingColor: primarySwatch[300]!,
        thirdRingColor: primarySwatch[100]!,
        size: 42,
      )),
    );
  }
}
