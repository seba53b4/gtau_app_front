import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/task_status.dart';
import '../models/value_label.dart';

class UserFilterProvider with ChangeNotifier {

  static const String notAssigned = "Sin_asignar";

  String? _userNameFilter;

  String? get userNameFilter => _userNameFilter;

  void setUserNameFilter(String? newName) {
    _userNameFilter = newName;
  }

  String? _emailFilter;

  String? get emailFilter => _emailFilter;

  void setEmailFilter(String newEmail) {
    _emailFilter = newEmail;
  }

  String? _firstnameFilter;

  String? get firstnameFilter => _firstnameFilter;

  void setFirstNameFilter(String? newFirstname) {
    _firstnameFilter = newFirstname;
  }

  String? _lastnameFilter;

  String? get lastnameFilter => _lastnameFilter;

  void setLastNameFilter(String? newLastname) {
    _lastnameFilter = newLastname;
  }

  String? _roleFilter;

  String? get roleFilter => _roleFilter;

  void setRoleFilter(String? newRole) {
    _roleFilter = newRole;
  }


  void resetFilters() {
    _userNameFilter = null;
    _emailFilter = null;
    _firstnameFilter = null;
    _lastnameFilter = null;
    _roleFilter = null;
    notifyListeners();
  }

  final List<ValueLabel> _suggestionsRoles = [
    ValueLabel(notAssigned, notAssigned),
    ValueLabel("Operador", 'OPERADOR'),
    ValueLabel("Administrador", 'ADMINISTRADOR'),
  ];

  List<ValueLabel> get suggestionsRoles => _suggestionsRoles;

  int getCurrentIndex() {
    return roleFilter == null
        ? 0
        : suggestionsRoles.map((e) => e.value).toList().indexOf(roleFilter!);
  }

  void search() {
    notifyListeners();
  }
}