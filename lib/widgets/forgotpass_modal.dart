import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtau_app_front/viewmodels/auth_viewmodel.dart';
import 'package:gtau_app_front/widgets/common/customDialog.dart';
import 'package:gtau_app_front/widgets/common/customMessageDialog.dart';
import 'package:gtau_app_front/widgets/common/custom_elevated_button.dart';
import 'package:gtau_app_front/widgets/common/custom_text_form_field.dart';
import 'package:gtau_app_front/widgets/loading_overlay.dart';
import 'package:provider/provider.dart';

import '../constants/theme_constants.dart';
import '../utils/common_utils.dart';
import 'common/button_circle.dart';

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
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final response = await authViewModel.recoverPassword(
          emailController.text, createBodyToChangePass());
      if (response) {
        printOnDebug('Se ha enviado mail de recuperacion de cuenta');
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
        printOnDebug('No se pudieron traer datos');
        return false;
      }
    } catch (error) {
      printOnDebug(error);
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

  Map<String, dynamic> createBodyToChangePass() {
    final Map<String, dynamic> requestBody = {"email": emailController.text};
    return requestBody;
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;

    return Consumer<AuthViewModel>(
      builder: (context, authviewModel, child) {
        bool isLoading = authviewModel.isLoading;
        return LoadingOverlay(
          isLoading: isLoading,
          child: Container(
            color: Colors.transparent,
            width: MediaQuery.of(context).size.width * 0.95,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: primarySwatch[400],
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      topLeft: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      ButtonCircle(
                        icon: Icons.close,
                        size: 50,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      Container(
                        width: kIsWeb ? 350 : 250,
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: kIsWeb ? 20 : 12,
                        ),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          appLocalizations.passwordrecovery_title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: lightBackground,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w300,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        appLocalizations.passwordrecovery_description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    CustomTextFormField(
                      width: kIsWeb
                          ? 280
                          : MediaQuery.of(context).size.width * 0.75,
                      hintText: appLocalizations.createUserPage_emailTitle,
                      controller: emailController,
                    ),
                    const SizedBox(height: 12),
                    CustomElevatedButton(
                      onPressed: () {
                        handleSubmit();
                        //Navigator.of(context).pop();
                      },
                      text: appLocalizations.buttonApplyLabel,
                    ),
                    const SizedBox(height: 12.0),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
