import 'package:flutter/material.dart';
import 'package:gtau_app_front/providers/user_provider.dart';
import 'package:gtau_app_front/screens/HomeScreen.dart';
import 'package:gtau_app_front/screens/ProfileScreen.dart';
import 'package:gtau_app_front/widgets/map_component.dart';
import 'package:provider/provider.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int myCurrentIndex = 0;


  List screens = [HomeScreen(), MapMobile(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    final userStateProvider = Provider.of<UserProvider>(context, listen: false);
    late List<BottomNavigationBarItem> optionsNav;
    if (userStateProvider.isAdmin!) {
      optionsNav = [
        const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Inicio',
      ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.add),
          label: 'Registrar',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Perfil',
        )
      ];
    } else {
      optionsNav = [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Perfil',
        )
      ];
      screens = [HomeScreen(), ProfileScreen()];

    }

    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: myCurrentIndex,
            onTap: (value) {
              setState(() {
                myCurrentIndex = value;
              });
            },
            items: optionsNav),
        body: screens[myCurrentIndex]);
  }
}

class MapMobile extends StatelessWidget {
  const MapMobile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: MapComponent(),
      ),
    );
  }
}