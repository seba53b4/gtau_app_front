import 'package:flutter/foundation.dart';

class AppContext with ChangeNotifier {
  bool isLoggedIn;
  dynamic user;

  AppContext({
    required this.isLoggedIn,
    required this.user,
  });

  void setIsLoggedIn(bool value) {
    isLoggedIn = value;
    notifyListeners();
  }

  void setUser(dynamic value) {
    user = value;
    notifyListeners();
  }
}

class AppContextProvider with ChangeNotifier {
  AppContext _appContext = AppContext(
    isLoggedIn: false,
    user: null,
  );

  AppContext get appContext => _appContext;

  void setIsLoggedIn(bool value) {
    _appContext.isLoggedIn = value;
    notifyListeners();
  }

  void setUser(dynamic value) {
    _appContext.user = value;
    notifyListeners();
  }
}