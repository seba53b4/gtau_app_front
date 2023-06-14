import 'package:flutter/material.dart';
import 'package:gtau_app_front/screens/HomeScreen.dart';
import 'package:gtau_app_front/screens/ProfileScreen.dart';

class NavigationWeb extends StatefulWidget {
  const NavigationWeb({super.key});

  @override
  State<NavigationWeb> createState() => _NavigationWeb();
}

class _NavigationWeb extends State<NavigationWeb> {
  int myCurrentIndex = 0;

  List screens = [HomeScreen(), ProfileScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Row(
      children: [
        NavigationRail(
          destinations: [
            NavigationRailDestination(
              icon: Icon(Icons.home),
              label: Text('Inicio'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.search),
              label: Text('Buscar'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.person),
              label: Text('Perfil'),
            ),
          ],
          selectedIndex: 0, // Índice seleccionado inicialmente
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
