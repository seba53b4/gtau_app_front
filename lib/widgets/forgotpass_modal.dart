import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtau_app_front/models/enums/message_type.dart';
import 'package:gtau_app_front/widgets/common/box_container.dart';
import 'package:gtau_app_front/widgets/common/customDialog.dart';
import 'package:gtau_app_front/widgets/common/customMessageDialog.dart';
import 'package:gtau_app_front/widgets/common/custom_elevated_button.dart';
import 'package:gtau_app_front/widgets/common/custom_text_form_field.dart';

class ForgotPassModal extends StatefulWidget {
  const ForgotPassModal({
    super.key,
  });

  @override
  State<ForgotPassModal> createState() => _ForgotPassModalState();
}

class _ForgotPassModalState extends State<ForgotPassModal> {
  double widthRow = 640;
  final emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<bool> _recoverPassword(BuildContext context) async {
    try {
      //final response = await taskListViewModel.createTask(token!, body);
      final response = true;
      if (response) {
        print('Se ha enviado mail de recuperacion de cuenta');
        await showCustomMessageDialog(
          context: context,
          customText: AppLocalizations.of(context)!.passwordrecovery_success,
          onAcceptPressed: () {},
          messageType: DialogMessageType.success,
        );
        return true;
      } else {
        await showCustomMessageDialog(
          context: context,
          customText: AppLocalizations.of(context)!.passwordrecovery_fail,
          onAcceptPressed: () {},
          messageType: DialogMessageType.error,
        );
        print('No se pudieron traer datos');
        return false;
      }
    } catch (error) {
      print(error);
      throw Exception('Error al obtener los datos');
    }
  }

  Future handleAcceptOnShowDialogPasswordRecovery(BuildContext context) async {
    bool isUpdated = await _recoverPassword(context);
    /*if (isUpdated) {
      reset();
    }*/
  }

  void handleSubmit() {
    showCustomDialog(
      context: context,
      title: AppLocalizations.of(context)!.dialogWarning,
      content: AppLocalizations.of(context)!.dialogContent,
      onDisablePressed: () {
        Navigator.of(context).pop();
      },
      onEnablePressed: () async {
        Navigator.of(context).pop();
        await handleAcceptOnShowDialogPasswordRecovery(context);
        Navigator.of(context).pop();
      },
      acceptButtonLabel: AppLocalizations.of(context)!.dialogAcceptButton,
      cancelbuttonLabel: AppLocalizations.of(context)!.dialogCancelButton,
    );
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
          appLocalizations.passwordrecovery_title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: kIsWeb ? 18 : 22),
        )),
      )),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FittedBox(
            fit: BoxFit.fill,
              child: BoxContainer(
              width: widthRow,
              alignment: Alignment.center,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const SizedBox(height: 24.0),
                    Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                        Text(
                          AppLocalizations.of(context)!.passwordrecovery_description,
                          style: const TextStyle(fontSize: 16.0),
                        ),
                        const SizedBox(height: 18.0),
                        CustomTextFormField(
                          width: widthRow,
                          hintText: AppLocalizations.of(context)!.createUserPage_emailTitle,
                          controller: emailController,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomElevatedButton(
                      onPressed: () {
                        handleSubmit();
                        //Navigator.of(context).pop();
                      },
                      text: appLocalizations.buttonApplyLabel,
                    ),
                    const SizedBox(height: 24.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}