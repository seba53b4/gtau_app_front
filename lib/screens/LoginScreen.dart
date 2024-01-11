import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtau_app_front/models/auth_data.dart';
import 'package:gtau_app_front/models/user_state.dart';
import 'package:gtau_app_front/navigation/navigation.dart';
import 'package:gtau_app_front/navigation/navigation_web.dart';
import 'package:gtau_app_front/providers/user_provider.dart';
import 'package:gtau_app_front/viewmodels/auth_viewmodel.dart';
import 'package:gtau_app_front/widgets/common/box_container.dart';
import 'package:provider/provider.dart';

import '../models/enums/message_type.dart';
import '../providers/task_filters_provider.dart';
import '../services/auth_service.dart';
import '../widgets/common/customMessageDialog.dart';
import '../widgets/common/custom_elevated_button.dart';
import '../widgets/common/custom_taost.dart';
import '../widgets/common/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  late AuthResult? authData;
  bool onError = false;

  Future<AuthResult?> _fetchAuth(
      BuildContext context, String username, String password) async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    return await authViewModel
        .fetchAuth(username, password)
        .catchError((error) async {
      // Manejo de error
      await showCustomMessageDialog(
        context: context,
        onAcceptPressed: () {},
        customText: AppLocalizations.of(context)!.error_service_not_available,
        messageType: DialogMessageType.error,
      );
      return null;
    });
  }

  _showWrongCredentialsToast(BuildContext context) {
    CustomToast.show(
      context,
      title: AppLocalizations.of(context)!.warning,
      message: AppLocalizations.of(context)!.login_warning_empty_input,
      type: MessageType.warning,
    );
  }

  void setUserData(BuildContext context, bool isLoggedIn, String username,
      AuthData authData, bool isAdmin) {
    if (isLoggedIn) {
      final filterProvider = context.read<TaskFilterProvider>();
      filterProvider.setUserNameFilter(username);
      final userStateProvider = context.read<UserProvider>();
      userStateProvider.updateUserState(UserState(
          username: username,
          isLoggedIn: true,
          authData: authData,
          isAdmin: isAdmin));
    }
  }

  goToNav(BuildContext context) {
    if (kIsWeb) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NavigationWeb()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BottomNavigation()),
      );
    }
  }

  Future<void> onLogInPressed(BuildContext context) async {
    final String username = usernameController.text;
    final String password = passwordController.text;

    if ((username.isEmpty || password.isEmpty)) {
      await _showWrongCredentialsToast(context);
      return;
    }

    AuthResult? authResponse = await _fetchAuth(context, username, password);

    if (context.mounted && authResponse?.authData != null) {
      setUserData(context, true, username, authResponse!.authData!,
          username == 'gtau-admin' ? true : false);
      goToNav(context);
    } else {
      setState(() {
        onError = true;
      });
      if (authResponse!.statusCode == 401) {
        CustomToast.show(
          context,
          title: AppLocalizations.of(context)!.error,
          message: AppLocalizations.of(context)!.login_error_auth,
          type: MessageType.error,
        );
      } else {
        await showCustomMessageDialog(
          context: context,
          onAcceptPressed: () {},
          customText: AppLocalizations.of(context)!.error_service_not_available,
          messageType: DialogMessageType.error,
        );
      }
    }
  }

  void onForgotPressed(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(builder: (context, authviewModel, child) {
      bool isLoading = authviewModel.isLoading;

      return Scaffold(
        body: Container(
          color: const Color.fromRGBO(253, 255, 252, 1),
          child: Center(
            child: BoxContainer(
              width: kIsWeb ? 400 : 340,
              height: kIsWeb ? 400 : 360,
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppLocalizations.of(context)!.titleApp),
                  const SizedBox(height: 24.0),
                  CustomTextField(
                    controller: usernameController,
                    hintText: AppLocalizations.of(context)!
                        .default_input_username_hint,
                    keyboardType: TextInputType.text,
                    obscureText: false,
                    hasError: onError,
                  ),
                  CustomTextField(
                    controller: passwordController,
                    hintText: AppLocalizations.of(context)!
                        .default_input_password_hint,
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    hasError: onError,
                  ),
                  const SizedBox(height: 16.0),
                  CustomElevatedButton(
                      showLoading: isLoading,
                      onPressed: () {
                        setState(() {
                          onError = false;
                        });
                        onLogInPressed(context);
                      },
                      text: AppLocalizations.of(context)!.default_login_button),
                  const SizedBox(height: kIsWeb ? 24 : 4),
                  TextButton(
                      onPressed: () => onForgotPressed(context),
                      child: Text(AppLocalizations.of(context)!
                          .default_forgot_password)),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
