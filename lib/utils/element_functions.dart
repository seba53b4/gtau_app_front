import 'package:flutter/cupertino.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

void scrollToFocusedElement({
  required FocusNode focusedNode,
  required ScrollController scrollController,
}) async {
  if (focusedNode.hasFocus) {
    Future.delayed(const Duration(milliseconds: 100), () async {
      final RenderObject object = focusedNode.context!.findRenderObject()!;
      await scrollController.position.ensureVisible(
        object,
        alignment: 0.5,
        duration: const Duration(milliseconds: 10),
        curve: Curves.easeInOut,
      );
    });
  }
}

void scrollToFocusedList(
    List<FocusNode> focusNodes, AutoScrollController scrollController) {
  FocusNode? focusedNode;

  for (var node in focusNodes) {
    if (node.hasFocus) {
      focusedNode = node;
      break;
    }
  }

  if (focusedNode != null) {
    scrollToFocusedElement(
      focusedNode: focusedNode,
      scrollController: scrollController,
    );
  }
}
