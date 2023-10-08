import 'package:flutter/foundation.dart';

class TaskFilterProvider with ChangeNotifier {
  String? _userNameFilter;

  String? get userNameFilter => _userNameFilter;

  String? _lastStatus;

  String? get lastStatus => _lastStatus;

  void setUserNameFilter(String? newName) {
    _userNameFilter = newName;
  }

  void setLastStatus(String lastStatus) {
    _lastStatus = lastStatus;
  }

  void resetFilters() {
    _userNameFilter = null;
  }
}
