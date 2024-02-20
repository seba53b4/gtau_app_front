import 'package:flutter/foundation.dart';

import '../models/auth_data.dart';
import '../models/user_state.dart';

class UserProvider with ChangeNotifier {
  UserState? _userState;

  UserState? get userState => _userState;

  void updateUserState(UserState userState) {
    _userState = userState;
    notifyListeners();
  }

  void updateUserStateAuthInfo(AuthData authData) {
    _userState!.setAuthData(authData);
    notifyListeners();
  }

  bool? get isUserDataEmpty => _userState?.isUserDataEmpty;

  void logout() {
    _userState?.reset();
    notifyListeners();
  }

  bool? get getIsLoggedIn => _userState?.getIsLoggedIn;

  bool? get isAdmin => _userState?.isAdmin;

  String? get getToken {
    return _userState?.authData?.accessToken;
  }

  String? get userName => _userState?.getUsername;
}
