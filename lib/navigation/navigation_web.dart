import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtau_app_front/providers/user_provider.dart';
import 'package:gtau_app_front/screens/HomeScreen.dart';
import 'package:gtau_app_front/screens/MapScreen.dart';
import 'package:gtau_app_front/screens/ProfileScreen.dart';
import 'package:gtau_app_front/screens/TaskCreationScreen.dart';
import 'package:provider/provider.dart';

import '../constants/theme_constants.dart';

class NavigationWeb extends StatefulWidget {
  const NavigationWeb({super.key});

  @override
  State<NavigationWeb> createState() => _NavigationWeb();
}

class _NavigationWeb extends State<NavigationWeb> {
  int myCurrentIndex = 1;
  late List<NavigationRailDestination> optionsNav;
  double iconSize = kIsWeb ? 28 : 24;
  bool isNavRailExtended = false;

  List screens = [
    const HomeScreen(),
    const MapScreen(),
    const ProfileScreen(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateOptionsNav();
  }

  void _updateOptionsNav() {
    final userStateProvider = Provider.of<UserProvider>(context, listen: false);
    NavigationRailDestination navHome = _buildCircularDestination(
        icon: Icon(Icons.home, size: iconSize),
        label: Text(AppLocalizations.of(context)!.navigation_label_home));

    NavigationRailDestination navAddTask = _buildCircularDestination(
        icon: Icon(Icons.add, size: iconSize),
        label: Text(AppLocalizations.of(context)!.navigation_label_task_add));

    NavigationRailDestination navMap = _buildCircularDestination(
        icon: Icon(Icons.map, size: iconSize),
        label: Text(AppLocalizations.of(context)!.navigation_label_map));

    NavigationRailDestination navProfile = _buildCircularDestination(
        icon: Icon(Icons.person, size: iconSize),
        label: Text(AppLocalizations.of(context)!.navigation_label_profile));

    if (userStateProvider.isAdmin!) {
      optionsNav = [
        navHome,
        navAddTask,
        navMap,
        navProfile,
      ];
      setState(() {
        screens = [
          const HomeScreen(),
          const HomeScreen(),
          TaskCreationScreen(
            type: '',
          ),
          const MapScreen(),
          const ProfileScreen(),
        ];
      });
    } else {
      optionsNav = [
        navHome,
        navMap,
        navProfile,
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            elevation: 150,
            extended: isNavRailExtended,
            backgroundColor: navColor,
            destinations: [
              NavigationRailDestination(
                icon: Icon(
                  isNavRailExtended ? Icons.menu_open : Icons.menu,
                ),
                label: Text('Cerrar'),
              ),
              ...optionsNav,
            ],
            selectedIndex: myCurrentIndex,
            onDestinationSelected: (int index) {
              setState(() {
                if (index != 0) {
                  myCurrentIndex = index;
                } else {
                  isNavRailExtended = !isNavRailExtended;
                }
              });
            },
          ),
          Expanded(
            child: screens[myCurrentIndex],
          ),
        ],
      ),
    );
  }

  NavigationRailDestination _buildCircularDestination(
      {required Widget icon, required Widget label, bool? isSelected}) {
    return NavigationRailDestination(
      label: label,
      icon: SizedBox(
        width: 40,
        height: 40,
        child: icon,
      ),
    );
  }
}
