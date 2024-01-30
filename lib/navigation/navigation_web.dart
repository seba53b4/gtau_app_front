import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gtau_app_front/assets/font/gtauicons.dart';
import 'package:gtau_app_front/screens/HomeScreen.dart';
import 'package:gtau_app_front/screens/MapScreen.dart';
import 'package:gtau_app_front/screens/ProfileScreen.dart';
import 'package:gtau_app_front/screens/TaskCreationScreen.dart';
import 'package:gtau_app_front/screens/UpdateElementsScreen.dart';
import 'package:gtau_app_front/screens/UserDashboardScreen.dart';

import '../constants/theme_constants.dart';

class NavigationWeb extends StatefulWidget {
  final bool isAdmin;

  const NavigationWeb({super.key, this.isAdmin = false});

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
    NavigationRailDestination navHome = _buildCircularDestination(
        icon: Icon(GtauIcons.home, size: iconSize),
        label: Text(AppLocalizations.of(context)!.navigation_label_home));

    NavigationRailDestination navAddTask = _buildCircularDestination(
        icon: Icon(GtauIcons.taskAdd, size: iconSize),
        label: Text(AppLocalizations.of(context)!.navigation_label_task_add));

    NavigationRailDestination navInfoUpdate = _buildCircularDestination(
        icon: Icon(Icons.update, size: iconSize),
        label: Text(
            AppLocalizations.of(context)!.navigation_label_update_elements));

    NavigationRailDestination navListUser = _buildCircularDestination(
        icon: Icon(GtauIcons.userList, size: iconSize),
        label: Text(AppLocalizations.of(context)!.listuser_title));

    NavigationRailDestination navMap = _buildCircularDestination(
        icon: Icon(GtauIcons.worldMap, size: iconSize),
        label: Text(AppLocalizations.of(context)!.navigation_label_map));

    NavigationRailDestination navProfile = _buildCircularDestination(
        icon: Icon(GtauIcons.userProfile, size: iconSize),
        label: Text(AppLocalizations.of(context)!.navigation_label_profile));

    if (widget.isAdmin) {
      optionsNav = [
        navHome,
        navAddTask,
        navInfoUpdate,
        navListUser,
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
          const UpdateElementsScreen(),
          const UserDashboardScreen(),
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
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.centerRight,
                colors: [
                  primarySwatch[100]!,
                  primarySwatch[50]!,
                ],
              ),
            ),
            child: NavigationRail(
              extended: isNavRailExtended,
              backgroundColor: Colors.transparent,
              useIndicator: true,
              indicatorColor: lightBackground,
              selectedLabelTextStyle: GoogleFonts.sora(
                textStyle: TextStyle(
                    color: lightBackground,
                    fontSize: 20,
                    fontWeight: FontWeight.w500),
              ),
              destinations: [
                if (kIsWeb)
                  NavigationRailDestination(
                    icon: Icon(
                      isNavRailExtended ? Icons.menu_open : Icons.menu,
                    ),
                    label: const Text(''),
                    padding: const EdgeInsets.only(bottom: 8),
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
          ),
          Expanded(
            child: screens[myCurrentIndex],
          ),
        ],
      ),
    );
  }

  NavigationRailDestination _buildCircularDestination(
      {required Widget icon, required Widget label}) {
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
