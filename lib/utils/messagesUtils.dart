import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widgets/common/customMessageDialog.dart';

void showGenericModalError(
    {required BuildContext context,
    Function? onAcceptPressed,
    String? message}) async {
  await showCustomMessageDialog(
    context: context,
    onAcceptPressed: () {
      if (onAcceptPressed != null) {
        onAcceptPressed();
      }
    },
    customText: message ?? AppLocalizations.of(context)!.error_generic_text,
    messageType: DialogMessageType.error,
  );
}
