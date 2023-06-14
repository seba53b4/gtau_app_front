import 'package:flutter/material.dart';
import 'package:gtau_app_front/screens/HomeScreen.dart';
import 'package:gtau_app_front/screens/ProfileScreen.dart';
import 'package:gtau_app_front/screens/TaskCreationScreen.dart';

class NavigationWeb extends StatefulWidget {
  const NavigationWeb({super.key});

  @override
  State<NavigationWeb> createState() => _NavigationWeb();
}

class _NavigationWeb extends State<NavigationWeb> {
  int myCurrentIndex = 0;

  List screens = [
    const HomeScreen(),
    TaskCreationScreen(
      type: '',
    ),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Row(
      children: [
        NavigationRail(
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.home),
              label: Text('Inicio'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.add),
              label: Text('Agregar tareas'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.person),
              label: Text('Perfil'),
            ),
          ],
          selectedIndex: myCurrentIndex, // Índice seleccionado inicialmente
          onDestinationSelected: (int index) {
            setState(() {
              myCurrentIndex = index;
            });
          },
        ),
        Expanded(child: screens[myCurrentIndex]),
      ],
    ));
  }
}
