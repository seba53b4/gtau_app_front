import 'package:flutter/material.dart';
import 'package:gtau_app_front/providers/user_provider.dart';
import 'package:gtau_app_front/screens/HomeScreen.dart';
import 'package:gtau_app_front/screens/MapScreen.dart';
import 'package:gtau_app_front/screens/ProfileScreen.dart';
import 'package:gtau_app_front/screens/TaskCreationScreen.dart';
import 'package:provider/provider.dart';

class NavigationWeb extends StatefulWidget {
  const NavigationWeb({super.key});

  @override
  State<NavigationWeb> createState() => _NavigationWeb();
}

class _NavigationWeb extends State<NavigationWeb> {
  int myCurrentIndex = 0;

  List screens = [
    const HomeScreen(),
    const MapScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {

    final userStateProvider = Provider.of<UserProvider>(context, listen: false);
    late List<NavigationRailDestination> optionsNav;
    if (userStateProvider.isAdmin!) {
      optionsNav = [
        const NavigationRailDestination(
          icon: Icon(Icons.home),
          label: Text('Inicio'),
        ),
        const NavigationRailDestination(
          icon: Icon(Icons.add),
          label: Text('Agregar tareas'),
        ),
        const NavigationRailDestination(
          icon: Icon(Icons.map),
          label: Text('Mapa'),
        ),
        const NavigationRailDestination(
          icon: Icon(Icons.person),
          label: Text('Perfil'),
        ),
      ];
      screens = [
        const HomeScreen(),
        TaskCreationScreen(
          type: '',
        ),
        const MapScreen(),
        const ProfileScreen(),
      ];
    } else {
      optionsNav = [
        const NavigationRailDestination(
          icon: Icon(Icons.home),
          label: Text('Inicio'),
        ),
        const NavigationRailDestination(
          icon: Icon(Icons.map),
          label: Text('Mapa'),
        ),
        const NavigationRailDestination(
          icon: Icon(Icons.person),
          label: Text('Perfil'),
        ),
      ];


    }

    return Scaffold(
        body: Row(
      children: [
        NavigationRail(
          destinations: optionsNav,
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
