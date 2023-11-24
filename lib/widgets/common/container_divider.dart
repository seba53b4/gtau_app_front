import 'package:flutter/material.dart';

class ContainerBottomDivider extends StatelessWidget {
  final List<Widget> children;

  const ContainerBottomDivider({Key? key, required this.children})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...children,
        const Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: 4),
          child: Divider(color: Colors.grey, thickness: 1),
        ),
      ],
    );
  }
}
