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
            const SizedBox(height: 50),
            const Text('Crear un nuevo usuario',
             style: TextStyle(
                  color: Color.fromARGB(255, 54, 54, 54),
                  fontSize: 16,
                ),
            ),
            const SizedBox(height: 25),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Alias/apodo del usuario',
              ),
              controller: usernameController,
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Nombre del usuario',
              ),
              controller: firstnameController,
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Apellido del usuario',
              ),
              controller: lastnameController,
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Email del usuario',
              ),
              controller: emailController,
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Contraseña',
              ),
              controller: passwordController,
              obscureText: true,
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Confirme la contraseña',
              ),
              controller: passwordConfirmController,
              obscureText: true,
            ),
            const SizedBox(height: 25),
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