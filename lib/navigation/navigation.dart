import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gtau_app_front/assets/font/gtauicons.dart';
import 'package:gtau_app_front/screens/HomeScreen.dart';
import 'package:gtau_app_front/screens/ProfileScreen.dart';
import 'package:gtau_app_front/widgets/map_component.dart';

import '../constants/theme_constants.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int myCurrentIndex = 0;

  List screens = [const HomeScreen(), const MapMobile(), const ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    late List<BottomNavigationBarItem> optionsNav = [
      _buildCircularDestination(
        icon: const Icon(Icons.home),
        label: AppLocalizations.of(context)!.navigation_label_home,
      ),
      _buildCircularDestination(
        icon: const Icon(GtauIcons.worldMap),
        label: AppLocalizations.of(context)!.navigation_label_map,
      ),
      _buildCircularDestination(
        icon: const Icon(GtauIcons.userProfile),
        label: AppLocalizations.of(context)!.navigation_label_profile,
      )
    ];

    return Scaffold(
        bottomNavigationBar: Container(
          height: 72,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                primarySwatch[100]!,
                primarySwatch[200]!,
              ],
            ),
          ),
          child: BottomNavigationBar(
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: lightBackground,
              selectedIconTheme: IconThemeData(color: lightBackground),
              selectedLabelStyle: GoogleFonts.sora(
                  color: lightBackground, fontWeight: FontWeight.w500),
              backgroundColor: Colors.transparent,
              currentIndex: myCurrentIndex,
              onTap: (value) {
                setState(() {
                  myCurrentIndex = value;
                });
              },
              items: optionsNav),
        ),
        body: screens[myCurrentIndex]);
  }
}

BottomNavigationBarItem _buildCircularDestination(
    {required Widget icon, required String? label}) {
  return BottomNavigationBarItem(
    label: label,
    icon: SizedBox(
      width: 40,
      height: 40,
      child: icon,
    ),
  );
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
