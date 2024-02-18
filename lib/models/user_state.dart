import 'auth_data.dart';

class UserState {
  late String? username;
  late bool? isLoggedIn;
  late bool? isAdmin;
  AuthData? authData;

  UserState({this.username, this.isLoggedIn, this.authData, this.isAdmin});

  String? get getUsername => username;

  set setUsername(String? value) => username = value;

  bool? get getIsLoggedIn => isLoggedIn;

  set setIsLoggedIn(bool? value) => isLoggedIn = value;

  String? get getJwt => authData?.accessToken;

  set setJwt(String? value) => authData?.accessToken = value!;

  bool? get getUserType => isAdmin;

  set setUserType(bool? value) => isAdmin = value;

  AuthData? get getAuthData => authData;

  void setAuthData(AuthData? value) {
    if (value != null) {
      authData = value;
    }
  }

  void reset() {
    username = null;
    isLoggedIn = false;
    authData = null;
  }

  bool get isUserDataEmpty {
    return username == null && isLoggedIn == false && isAdmin == null;
  }
}
