class UserInfo {
  late final String username;
  late final String rol;

  UserInfo({
    required this.username,
    required this.rol,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      username: json['username'],
      rol: json['rol'],
    );
  }
}
