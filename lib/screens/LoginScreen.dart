import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gtau_app_front/models/auth_data.dart';
import 'package:gtau_app_front/models/user_state.dart';
import 'package:gtau_app_front/navigation/navigation.dart';
import 'package:gtau_app_front/navigation/navigation_web.dart';
import 'package:gtau_app_front/providers/user_provider.dart';
import 'package:gtau_app_front/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';



class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  late AuthData? authData;

  Future<AuthData?> _fetchAuth(BuildContext context, String username, String password) async {

    if (username.isEmpty || password.isEmpty){
      _showWrongCredentialsToast(context);
      return null;
    }

    try {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final responseAuthData = await authViewModel.fetchAuth(username, password);

      if (responseAuthData != null) {
        return responseAuthData;
      } else {
        print('Contraseña incorrecta');
        _showWrongCredentialsToast(context);
        return null;
      }
    } catch (error) {
      print(error);
      throw Exception('Error al obtener los datos');
    }
  }

  _showWrongCredentialsToast(BuildContext context){
    Fluttertoast.showToast(
      msg: AppLocalizations.of(context)!.toast_warning_wrong_credentials,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
    );
  }

  void setUserData(BuildContext context, bool isLoggedIn, String username, AuthData authData, bool isAdmin) {
    if (isLoggedIn) {
      final userStateProvider = context.read<UserProvider>();
      userStateProvider.updateUserState(UserState(
        username: username,
        isLoggedIn: true,
        authData: authData,
        isAdmin: isAdmin
      ));
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

    AuthData? authData = await _fetchAuth(context, username, password);
    if (context.mounted && authData != null) {
      setUserData(context, true, username, authData, username == 'gtau-admin' ? true: false);
      goToNav(context);
    }
  }

  void onForgotPressed() {
    print('Wrong');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(16.0),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('PipeTracker'),
            TextField(
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.default_input_username_hint,
              ),
              controller: usernameController,
            ),
            TextField(
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.default_input_password_hint,
              ),
              controller: passwordController,
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () => onLogInPressed(context),
              child: Text(AppLocalizations.of(context)!.default_login_button),
            ),
            ElevatedButton(
              onPressed: onForgotPressed,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.grey),
              ),
              child: Text(AppLocalizations.of(context)!.default_forgot_password),
            ),
          ],
        ),
      ),
    );
  }
}
