import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final double? width;
  final double? height;

  const LoadingWidget({super.key, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: width ?? screenWidth,
      height: height ?? screenHeight,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
