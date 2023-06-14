import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:gtau_app_front/navigation/navigation.dart';
import 'package:gtau_app_front/navigation/navigation_web.dart';
import 'package:gtau_app_front/screens/HomeScreen.dart';
import 'package:gtau_app_front/screens/ProfileScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // Navegación para aplicaciones web
      return const MaterialApp(home: NavigationWeb());
    } else {
      // Navegación para aplicaciones móviles
      return const MaterialApp(
        home: BottomNavigation(),
      );
    }
  }
}
