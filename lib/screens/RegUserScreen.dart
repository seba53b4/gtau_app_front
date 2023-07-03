import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gtau_app_front/models/user_state.dart';
import 'package:gtau_app_front/navigation/navigation.dart';
import 'package:gtau_app_front/navigation/navigation_web.dart';




class RegUserScreen extends StatelessWidget {
  RegUserScreen({super.key});

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmController = TextEditingController();

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

  Future<void> onRegUserPressed(BuildContext context) async {
    final String username = usernameController.text;
    final String firstname = firstnameController.text;
    final String lastname = lastnameController.text;
    final String email = emailController.text;
    final String password = passwordController.text;
    final String passwordConfirm = passwordConfirmController.text;

    if(password==passwordConfirm){
      goToNav(context);
    }
    
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
            const Text('Crear un nuevo usuario'),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Alias/apodo del usuario',
              ),
              controller: usernameController,
            ),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Nombre del usuario',
              ),
              controller: firstnameController,
            ),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Apellido del usuario',
              ),
              controller: lastnameController,
            ),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Email del usuario',
              ),
              controller: emailController,
            ),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Contraseña',
              ),
              controller: passwordController,
              obscureText: true,
            ),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Confirme la contraseña',
              ),
              controller: passwordConfirmController,
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () => onRegUserPressed(context),
              child: const Text('Siguiente'),
            ),
          ],
        ),
      ),
    );
  }
}