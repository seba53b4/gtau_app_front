import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gtau_app_front/screens/LoginScreen.dart';
import 'package:gtau_app_front/widgets/loading_overlay.dart';
import 'package:provider/provider.dart';

import '../constants/theme_constants.dart';
import '../models/auth_data.dart';
import '../models/enums/message_type.dart';
import '../models/user_state.dart';
import '../navigation/navigation.dart';
import '../navigation/navigation_web.dart';
import '../providers/user_provider.dart';
import '../services/auth_service.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/common/custom_taost.dart';

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
    checkLoginStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> checkLoginStatus() async {
    setState(() {
      loading = true;
    });
    String? storedAccessToken = await _storage.read(key: 'access_token');

    if (storedAccessToken != null) {
      await loadUserStateFromStorage();
      if (!isTokenExpired(storedAccessToken)) {
        setState(() {
          accessToken = storedAccessToken;
        });
      } else {
        updateAuthStored();
      }
      setState(() {
        isLoggedIn = true;
      });
    }
    setState(() {
      loading = false;
    });
    return;
  }

  void updateAuthStored() async {
    AuthViewModel authViewModel =
        Provider.of<AuthViewModel>(context, listen: false);
    String? refreshTokenStore = await _storage.read(key: 'refresh_token');
    if (refreshTokenStore != null) {
      AuthResult? refreshData =
          await authViewModel.refreshAuth(refreshTokenStore);

      if (refreshData != null && refreshData.authData != null) {
        userStateProvider.updateUserStateAuthInfo(refreshData.authData!);
        await _storage.write(
            key: 'access_token', value: refreshData.authData!.accessToken);
        await _storage.write(
            key: 'refresh_token', value: refreshData.authData!.refreshToken);
      } else {
        logoutSession();
      }
    }
  }

  void deleteSessionData() {
    _storage.delete(key: 'refresh_token');
    _storage.delete(key: 'access_token');
    _storage.delete(key: 'username');
    _storage.delete(key: 'isAdmin');
  }

  void logoutSession() async {
    userStateProvider.logout();
    deleteSessionData();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
    await _showExpiredSessionToast(context);
  }

  _showExpiredSessionToast(BuildContext context) {
    CustomToast.show(
      context,
      title: AppLocalizations.of(context)!.warning,
      message: AppLocalizations.of(context)!.session_expired_msg,
      type: MessageType.warning,
    );
  }

  void updateUserState(
      {required bool isLoggedIn,
      required bool isAdmin,
      required String username,
      required AuthData authData}) {
    userStateProvider.updateUserState(UserState(
        isLoggedIn: isLoggedIn,
        isAdmin: isAdmin,
        username: username,
        authData: authData));
  }

  Future<void> loadUserStateFromStorage() async {
    String? accessTokenStore = await _storage.read(key: 'access_token');
    String? refreshTokenStore = await _storage.read(key: 'refresh_token');
    String? isAdminStore = await _storage.read(key: 'isAdmin');
    String? usernameStore = await _storage.read(key: 'username');

    updateUserState(
        isLoggedIn: true,
        isAdmin: isAdminStore == 'true',
        username: usernameStore!,
        authData: AuthData(
            accessToken: accessTokenStore!, refreshToken: refreshTokenStore!));
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
    return Consumer<UserProvider>(builder: (context, userProvider, _) {
      return loading
          ? LoadingOverlay(
              isLoading: true,
              child: Container(color: lightBackground, child: LoginScreen()))
          : !isLoggedIn
              ? LoginScreen()
              : kIsWeb && isLoggedIn
                  ? NavigationWeb(isAdmin: userProvider.isAdmin ?? false)
                  : const BottomNavigation();
    });
  }
}
