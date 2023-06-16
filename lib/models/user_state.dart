
class UserState {
  late String? username;
  late bool? isLoggedIn;
  late String? jwt;
  // Otros campos de información de usuario

  UserState({this.username, this.isLoggedIn, this.jwt});

  String? get getUsername => username;
  set setUsername(String? value) => username = value;

  bool? get getIsLoggedIn => isLoggedIn;
  set setIsLoggedIn(bool? value) => isLoggedIn = value;

  String? get getJwt => jwt;
  set setJwt(String? value) => jwt = value;

  void reset() {
    username = null;
    isLoggedIn = false;
    jwt = null;
  }

  bool get isUserDataEmpty {
    return username == null && isLoggedIn == false && jwt == null;
  }
}

