import 'package:flutter/cupertino.dart';

void scrollToFocusedElement({
  required FocusNode focusedNode,
  required ScrollController scrollController,
}) async {
  if (focusedNode.hasFocus) {
    Future.delayed(const Duration(milliseconds: 80), () async {
      final RenderObject object = focusedNode.context!.findRenderObject()!;
      await scrollController.position.ensureVisible(
        object,
        alignment: 0.5,
        duration: const Duration(milliseconds: 20),
        curve: Curves.easeInOut,
      );
    });
  }
}
