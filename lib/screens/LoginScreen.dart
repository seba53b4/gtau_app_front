import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gtau_app_front/constants/theme_constants.dart';
import 'package:gtau_app_front/models/auth_data.dart';
import 'package:gtau_app_front/models/user_info.dart';
import 'package:gtau_app_front/models/user_state.dart';
import 'package:gtau_app_front/navigation/navigation.dart';
import 'package:gtau_app_front/navigation/navigation_web.dart';
import 'package:gtau_app_front/providers/user_provider.dart';
import 'package:gtau_app_front/viewmodels/auth_viewmodel.dart';
import 'package:gtau_app_front/widgets/common/background_gradient.dart';
import 'package:gtau_app_front/widgets/common/box_container_white.dart';
import 'package:gtau_app_front/widgets/common/custom_elevated_button_length.dart';
import 'package:provider/provider.dart';

import '../models/enums/message_type.dart';
import '../providers/task_filters_provider.dart';
import '../services/auth_service.dart';
import '../widgets/common/customMessageDialog.dart';
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
  bool isLoggedIn = false;
  bool isAdmin = false;
  String accessToken = '';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late UserProvider userStateProvider;

  @override
  void initState() {
    super.initState();
    userStateProvider = context.read<UserProvider>();
  }

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

  Future<String?> _getUserRole(String token) async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    UserInfo? userInfo =
        await authViewModel.getUserRole(token).catchError((error) async {
      // Manejo de error
      await showCustomMessageDialog(
        context: context,
        onAcceptPressed: () {},
        customText: AppLocalizations.of(context)!.error_service_not_available,
        messageType: DialogMessageType.error,
      );
      return null;
    });

    if (userInfo != null) {
      return userInfo.rol;
    }
    return null;
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
      AuthData authData, bool isAdminUser) async {
    if (isLoggedIn) {
      final filterProvider = context.read<TaskFilterProvider>();
      filterProvider.setUserNameFilter(username);
      userStateProvider.updateUserState(UserState(
          username: username,
          isLoggedIn: true,
          authData: authData,
          isAdmin: isAdminUser));
      setState(() {
        isAdmin = isAdminUser;
      });
      await _storage.write(key: 'access_token', value: authData.accessToken);
      await _storage.write(key: 'refresh_token', value: authData.refreshToken);
      await _storage.write(key: 'isAdmin', value: isAdminUser.toString());
      await _storage.write(key: 'username', value: username);
    }
  }

  goToNav(BuildContext context) async {
    if (kIsWeb) {
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => NavigationWeb(isAdmin: isAdmin)),
      );
    } else {
      await Navigator.pushReplacement(
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
      String? admin = await _getUserRole(authResponse!.authData!.accessToken);
      setUserData(context, true, username, authResponse!.authData!,
          admin == 'ADMINISTRADOR' ? true : false);
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

  void _submitForm(BuildContext context) {
    if (kIsWeb) {
      setState(() {
        onError = false;
      });
      onLogInPressed(context);
    }
  }

  void onForgotPressed(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(builder: (context, authviewModel, child) {
      bool isLoading = authviewModel.isLoading;
      if (kIsWeb) {
        return Scaffold(
          body: BackgroundGradient(
            colors: [primarySwatch[400]!, primarySwatch[600]!],
            child: Center(
              child: FittedBox(
                child: BoxContainerWhite(
                  withBorder: false,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: SvgPicture.asset(
                          'lib/assets/tunnel_logo_final.svg',
                          width: 200,
                          height: 200,
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      CustomTextField(
                        controller: usernameController,
                        hintText: AppLocalizations.of(context)!
                            .default_input_username_hint,
                        keyboardType: TextInputType.text,
                        obscureText: false,
                        width: 400,
                        hasError: onError,
                        onSubmitted: (_) => _submitForm(context),
                      ),
                      CustomTextField(
                        controller: passwordController,
                        hintText: AppLocalizations.of(context)!
                            .default_input_password_hint,
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        width: 400,
                        hasError: onError,
                        onSubmitted: (_) => _submitForm(context),
                      ),
                      const SizedBox(height: 16.0),
                      CustomElevatedButtonLength(
                          showLoading: isLoading,
                          width: 400,
                          onPressed: () {
                            setState(() {
                              onError = false;
                            });
                            onLogInPressed(context);
                          },
                          text: AppLocalizations.of(context)!
                              .default_login_button),
                      const SizedBox(height: kIsWeb ? 24 : 4),
                      TextButton(
                          onPressed: () => onForgotPressed(context),
                          child: Text(
                              AppLocalizations.of(context)!
                                  .default_forgot_password,
                              style: TextStyle(color: subtitleColor))),
                      const SizedBox(height: 16.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      } else {
        return Scaffold(
          body: Container(
            color: const Color.fromRGBO(253, 255, 252, 1),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width * 0.9,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset('lib/assets/tunnel_logo_text.svg',
                        width: 50, height: 50),
                    const SizedBox(height: 24.0),
                    CustomTextField(
                      controller: usernameController,
                      hintText: AppLocalizations.of(context)!
                          .default_input_username_hint,
                      keyboardType: TextInputType.text,
                      obscureText: false,
                      width: MediaQuery.of(context).size.width,
                      hasError: onError,
                    ),
                    CustomTextField(
                      controller: passwordController,
                      hintText: AppLocalizations.of(context)!
                          .default_input_password_hint,
                      keyboardType: TextInputType.text,
                      obscureText: true,
                      width: MediaQuery.of(context).size.width,
                      hasError: onError,
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextButton(
                          onPressed: () => onForgotPressed(context),
                          child: Text(
                              AppLocalizations.of(context)!
                                  .default_forgot_password,
                              style: TextStyle(color: subtitleColor))),
                    ),
                    const SizedBox(height: kIsWeb ? 24 : 4),
                    CustomElevatedButtonLength(
                        width: 400,
                        showLoading: isLoading,
                        onPressed: () {
                          setState(() {
                            onError = false;
                          });
                          onLogInPressed(context);
                        },
                        text:
                            AppLocalizations.of(context)!.default_login_button),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    });
  }
}
