import 'package:flutter/material.dart';
import 'package:gtau_app_front/widgets/loading_component.dart';

import '../constants/theme_constants.dart';

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;

  LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        if (!isLoading) child,
        if (isLoading)
          Stack(
            children: [
              child,
              Container(color: overlayColor, child: const LoadingWidget()),
            ],
          ),
      ],
    );
  }
}
