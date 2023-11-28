import 'package:flutter/cupertino.dart';

import 'customMessageDialog.dart';

class ErrorDialogHandler extends StatelessWidget {
  final bool showError;
  final VoidCallback onAcceptPressed;
  final String? customText;

  const ErrorDialogHandler({
    required this.showError,
    required this.onAcceptPressed,
    Key? key,
    this.customText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(

      future: showError ? Future.error("Simulated Error") : Future.value(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasError) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await showCustomMessageDialog(
              context: context,
              onAcceptPressed: onAcceptPressed,
              customText: customText ?? '',
              messageType: DialogMessageType.error,
            );
          });
        }

        return const SizedBox.shrink();
      },
    );
  }
}
