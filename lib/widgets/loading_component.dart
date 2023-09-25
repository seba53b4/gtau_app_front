import 'package:flutter/material.dart';

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
      child: const Center(
        child: CircularProgressIndicator(
          color: Color.fromRGBO(96, 166, 27, 1),
        ),
      ),
    );
  }
}
