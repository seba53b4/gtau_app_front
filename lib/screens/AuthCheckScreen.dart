import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gtau_app_front/screens/LoginScreen.dart';
import 'package:gtau_app_front/widgets/loading_overlay.dart';
import 'package:provider/provider.dart';

import '../constants/theme_constants.dart';
import '../models/auth_data.dart';
import '../models/user_state.dart';
import '../navigation/navigation.dart';
import '../navigation/navigation_web.dart';
import '../providers/user_provider.dart';

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  _AuthCheckState createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  bool isLoggedIn = false;
  String accessToken = '';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late UserProvider userStateProvider;
  bool loading = true;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    userStateProvider = context.read<UserProvider>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    setState(() {
      loading = true;
    });
    String? storedAccessToken = await _storage.read(key: 'access_token');

    if (storedAccessToken != null) {
      if (!isTokenExpired(storedAccessToken)) {
        setState(() {
          isLoggedIn = true;
          accessToken = storedAccessToken;
        });
        loadUserStateFromStorage();
      }
    }
    setState(() {
      loading = false;
    });
    return;
  }

  void loadUserStateFromStorage() async {
    String? accessToken = await _storage.read(key: 'access_token');
    String? refreshToken = await _storage.read(key: 'refresh_token');
    String? isAdminStore = await _storage.read(key: 'isAdmin');
    String? username = await _storage.read(key: 'username');
    setState(() {
      isAdmin = isAdminStore == 'true';
    });
    userStateProvider.updateUserState(UserState(
        isLoggedIn: true,
        isAdmin: isAdmin,
        username: username,
        authData:
            AuthData(accessToken: accessToken!, refreshToken: refreshToken!)));
  }

  bool isTokenExpired(String accessToken) {
    try {
      Map<String, dynamic> decodedToken =
          json.decode(utf8.decode(base64Url.decode(accessToken.split('.')[1])));

      int expTimestamp = decodedToken['exp'];

      DateTime expirationDate =
          DateTime.fromMillisecondsSinceEpoch(expTimestamp * 1000);

      return DateTime.now().isAfter(expirationDate);
    } catch (e) {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? LoadingOverlay(
            isLoading: true,
            child: Container(
              color: lightBackground,
            ))
        : !isLoggedIn
            ? LoginScreen()
            : kIsWeb && isLoggedIn
                ? NavigationWeb(isAdmin: isAdmin)
                : const BottomNavigation();
  }
}
