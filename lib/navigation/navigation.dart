import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtau_app_front/screens/HomeScreen.dart';
import 'package:gtau_app_front/screens/ProfileScreen.dart';
import 'package:gtau_app_front/widgets/map_component.dart';

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
    late List<BottomNavigationBarItem> optionsNav = [
      BottomNavigationBarItem(
        icon: const Icon(Icons.home),
        label: AppLocalizations.of(context)!.navigation_label_home,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.add),
        label: AppLocalizations.of(context)!.navigation_label_map,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.person),
        label: AppLocalizations.of(context)!.navigation_label_profile,
      )
    ];

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
    return const Scaffold(
      body: Center(
        child: MapComponent(),
      ),
    );
  }
}
