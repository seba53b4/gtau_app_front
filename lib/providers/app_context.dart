import 'package:flutter/foundation.dart';

class AppContext {
  bool isWeb;
  bool isLoggedIn;
  dynamic user;

  AppContext({
    required this.isWeb,
    required this.isLoggedIn,
    required this.user,
  });
}

class AppContextProvider with ChangeNotifier {
  AppContext _appContext = AppContext(
    isWeb: false,
    isLoggedIn: false,
    user: null,
  );

  AppContext get appContext => _appContext;

  void setIsWeb(bool value) {
    _appContext.isWeb = value;
    notifyListeners();
  }

  void setIsLoggedIn(bool value) {
    _appContext.isLoggedIn = value;
    notifyListeners();
  }

  void setUser(dynamic value) {
    _appContext.user = value;
    notifyListeners();
  }
}