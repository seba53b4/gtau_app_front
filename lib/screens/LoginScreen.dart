import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gtau_app_front/models/user_state.dart';
import 'package:gtau_app_front/navigation/navigation.dart';
import 'package:gtau_app_front/navigation/navigation_web.dart';
import 'package:gtau_app_front/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  late String jwt = '';

  Future<bool> fetchAuthMock(String username, String password) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/users'));
      final data = json.decode(response.body);

      if (data is List) {
        for (var user in data) {
          if (user['username'] == username && user['password'] == password) {
            print('Usuario y contraseña válidos');
            return true;
          }
        }
      }
      print('contraseña incorrecta');
      return false;
    } catch (error) {
      print(error);
      throw Exception('Error al obtener los datos');
    }
  }

  Future<bool> fetchAuth(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8083/auth/realms/gtau/protocol/openid-connect/token'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Basic Z3RhdS1jbGllbnQ6JDdXZE43Qk54MmFkSkV5Mjg1d0oyNSMm',
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
        // La solicitud fue exitosa
        print('Usuario y contraseña válidos');
        jwt = data.jwt;
        return true;
      } else {
        // La solicitud no fue exitosa
        print('Contraseña incorrecta');
        return false;
      }
    } catch (error) {
      print(error);
      throw Exception('Error al obtener los datos');
    }
  }

  void setUserData(BuildContext context, bool isLoggedIn, String username, String jwt) {
    if (isLoggedIn) {
      final userStateProvider = context.read<UserProvider>();
      userStateProvider.updateUserState(UserState(
        username: username,
        isLoggedIn: true,
        jwt: jwt,
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

    bool isLoggedIn = await fetchAuthMock(username, password);
    if (context.mounted && isLoggedIn) {
      setUserData(context, isLoggedIn, username, jwt);
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
