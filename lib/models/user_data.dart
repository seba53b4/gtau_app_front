class UserData {
  late String? id;
  late String? email;
  late String? firstName;
  late String? lastName;
  late String? username;
  late String? rol;
  

  String? get getId => id;

  set setId(String? value) => id = value;

  String? get getEmail => email;

  set setEmail(String? value) => email = value;

  String? get getFirstname => firstName;

  set setFirstname(String? value) => firstName = value;

  String? get getLastname => lastName;

  set setLastname(String? value) => lastName = value;

  String? get getUsername => username;

  set setUsername(String? value) => username = value;

  String? get getRol => rol;

  set setRol(String? value) => rol = value;

 

  UserData(
      {required this.id,
      required this.email,
      required this.firstName,
      required this.lastName,
      required this.username,
      required this.rol});
}