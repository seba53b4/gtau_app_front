import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gtau_app_front/providers/app_context.dart';


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
      final appContextProvider = Provider.of<AppContextProvider>(context, listen: false);
      appContextProvider.setIsLoggedIn(true);
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

    final appContextProvider = Provider.of<AppContextProvider>(context);
    final appContext = appContextProvider.appContext;

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

