import 'package:flutter/cupertino.dart';

import 'customMessageDialog.dart';

class ErrorDialogHandler extends StatefulWidget {
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
  _ErrorDialogHandlerState createState() => _ErrorDialogHandlerState();
}

class _ErrorDialogHandlerState extends State<ErrorDialogHandler>
    with SingleTickerProviderStateMixin {
  static bool errorDialogShown = false;

  @override
  void initState() {
    super.initState();

    if (widget.showError && !errorDialogShown) {
      errorDialogShown = true;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await showCustomMessageDialog(
          context: context,
          onAcceptPressed: () {
            widget.onAcceptPressed();
            errorDialogShown = false;
          },
          customText: widget.customText ?? '',
          messageType: DialogMessageType.error,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
