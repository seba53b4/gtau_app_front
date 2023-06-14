import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:gtau_app_front/navigation/navigation.dart';
import 'package:gtau_app_front/navigation/navigation_web.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // Navegación para web
      return const MaterialApp(home: NavigationWeb());
    } else {
      // Navegación para mobile
      return const MaterialApp(
        home: BottomNavigation(),
      );
    }
  }
}
