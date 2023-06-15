import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gtau_app_front/models/user_state.dart';
import 'package:gtau_app_front/navigation/navigation.dart';
import 'package:gtau_app_front/navigation/navigation_web.dart';
import 'package:gtau_app_front/providers/user_provider.dart';
import 'package:provider/provider.dart';


class LoginScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void onLogInPressed(BuildContext context) {
    final String username = usernameController.text;
    final String password = passwordController.text;

    if (isEmpty(username) || isEmpty(password)) {
      print('Username and/or password fields are empty');
    } else {
      print('Logging in $username');

      final userStateProvider = Provider.of<UserProvider>(context, listen: false);
      userStateProvider.updateUserState(UserState(
        username: username,
        isLoggedIn: true,
        jwt: 'jwt-here',
      ));

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
  }

  void onForgotPressed() {
    print('Wrong');
  }

  bool isEmpty(String str) {
    return (str == null || str.isEmpty);
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
              decoration: const InputDecoration(
                hintText: 'Nombre del usuario',
              ),
              controller: usernameController,
            ),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Ingresa la password',
              ),
              controller: passwordController,
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () => onLogInPressed(context),
              child: const Text('Login button'),
            ),
            ElevatedButton(
              onPressed: onForgotPressed,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.grey),
              ),
              child: const Text('Olvidaste la password'),
            ),
          ],
        ),
      ),
    );
  }
}

