import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtau_app_front/models/enums/message_type.dart';
import 'package:gtau_app_front/widgets/common/box_container.dart';
import 'package:gtau_app_front/widgets/common/custom_elevated_button.dart';

class ForgotPassModal extends StatefulWidget {
  const ForgotPassModal({
    super.key,
  });

  @override
  State<ForgotPassModal> createState() => _ForgotPassModalState();
}

class _ForgotPassModalState extends State<ForgotPassModal> {
  double widthRow = 640;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
          title: Padding(
        padding: const EdgeInsets.only(right: 80),
        child: Center(
            child: Text(
          appLocalizations.filter_task_title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: kIsWeb ? 18 : 22),
        )),
      )),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BoxContainer(
            width: widthRow,
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 50,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  messageType: MessageType.error,
                                  text: appLocalizations.buttonCleanLabel,
                                ),
                                const SizedBox(width: 10.0),
                                CustomElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  text: appLocalizations.buttonApplyLabel,
                                ),
                              ]),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}