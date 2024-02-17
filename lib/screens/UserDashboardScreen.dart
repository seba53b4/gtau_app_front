import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gtau_app_front/assets/font/gtauicons.dart';
import 'package:gtau_app_front/constants/theme_constants.dart';
import 'package:gtau_app_front/screens/UserCreationScreen.dart';
import 'package:gtau_app_front/widgets/common/background_gradient.dart';
import 'package:gtau_app_front/widgets/common/box_container_white.dart';
import 'package:gtau_app_front/widgets/common/custom_elevated_icon_button.dart';
import 'package:gtau_app_front/widgets/user_dashboard.dart';
import 'package:gtau_app_front/widgets/user_filter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({Key? key});

  @override
  _UserDashboardScreen createState() => _UserDashboardScreen();
}

class _UserDashboardScreen extends State<UserDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }


  Future<bool> _clearPref() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }

  void _showAddUserModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
              side: BorderSide(width: 6.0, color: boxContainerBorder),
              borderRadius: const BorderRadius.all(Radius.circular(50.0))),
          child: SizedBox(
            width: 700,
            height: 536,
            child: UserCreationScreen(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _clearPref();
    return Scaffold(
      body: BackgroundGradient(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 52),
              Container(
                width: 900,
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CustomElevatedIconButton(
                      textColor: primarySwatch[700],
                      backgroundColor: Colors.white,
                      onPressed: () {
                        _showAddUserModal(context);
                      },
                      icon: GtauIcons.userAdd,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                color: Colors.transparent,
                child: Center(
                  child: Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                    height: kIsWeb
                        ? MediaQuery
                        .of(context)
                        .size
                        .height * 0.78
                        : MediaQuery
                        .of(context)
                        .size
                        .height - 72,
                    color: Colors.transparent,
                    child: _constraintBoxUserDashboard(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showFilterModal(context);
        },
        foregroundColor: primarySwatch[700]!,
        backgroundColor: Colors.white,
        shape: null,
        child: const Icon(Icons.filter_alt_rounded),
      ),
    );
  }
}

void _showFilterModal(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(50.0))),
        child: SizedBox(
          width: kIsWeb ? 640 : MediaQuery
              .of(context)
              .size
              .width,
          height: 600,
          child: const UserFilter(),
        ),
      );
    },
  );
}

Widget _constraintBoxUserDashboard(BuildContext context) {
  double widthDashboard = 980;
  double paddingDashboard =
  (MediaQuery
      .of(context)
      .size
      .width - widthDashboard) > 0 && kIsWeb
      ? (MediaQuery
      .of(context)
      .size
      .width - widthDashboard) / 2
      : 0;
  return BoxContainerWhite(
    decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
    margin: kIsWeb
        ? EdgeInsets.symmetric(horizontal: paddingDashboard)
        : const EdgeInsets.symmetric(horizontal: 0),
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery
            .of(context)
            .size
            .width,
        maxHeight: kIsWeb
            ? MediaQuery
            .of(context)
            .size
            .height * 0.78
            : MediaQuery
            .of(context)
            .size
            .height - 164,
      ),
      child: const UserDashboard(),
    ),
  );
}
