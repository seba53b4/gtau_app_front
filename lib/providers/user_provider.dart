import 'package:flutter/foundation.dart';
import '../models/user_state.dart';

class UserProvider with ChangeNotifier {
  UserState? _userState;

  UserState? get userState => _userState;

  void updateUserState(UserState userState) {
    _userState = userState;
    notifyListeners();
  }

  bool? get isUserDataEmpty => _userState?.isUserDataEmpty;

  void logout(){
    _userState?.reset();
    notifyListeners();
  }
  bool? get getIsLoggedIn => _userState?.getIsLoggedIn;

  bool? get isAdmin => _userState?.isAdmin;
}