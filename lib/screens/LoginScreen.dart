import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gtau_app_front/models/user_state.dart';
import 'package:gtau_app_front/navigation/navigation.dart';
import 'package:gtau_app_front/navigation/navigation_web.dart';
import 'package:gtau_app_front/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';



class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  late String jwt = '';

  Future<bool> fetchAuth(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(dotenv.get('API_AUTH', fallback: 'NOT_FOUND')),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': "Basic ${dotenv.get('API_AUTHORIZATION', fallback: 'NOT_FOUND')}",
        },
        body: {
          'grant_type': 'password',
          'username': username,
          'password': password,
          'scope': 'openid profile roles',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        print('Usuario y contraseña válidos');
        jwt = data['access_token'];
        return true;
      } else {
        print('Contraseña incorrecta');
        Fluttertoast.showToast(
          msg: "Usuario y/o contraseña incorrectos",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
        );
        return false;
      }
    } catch (error) {
      print(error);
      throw Exception('Error al obtener los datos');
    }
  }

  void setUserData(BuildContext context, bool isLoggedIn, String username, String jwt, bool isAdmin) {
    if (isLoggedIn) {
      final userStateProvider = context.read<UserProvider>();
      userStateProvider.updateUserState(UserState(
        username: username,
        isLoggedIn: true,
        jwt: jwt,
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

    bool isLoggedIn = await fetchAuth(username, password);
    if (context.mounted && isLoggedIn) {
      setUserData(context, isLoggedIn, username, jwt, username == 'gtau-admin' ? true: false);
      goToNav(context);
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
