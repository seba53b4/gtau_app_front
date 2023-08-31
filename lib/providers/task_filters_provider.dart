import 'package:flutter/foundation.dart';

class TaskFilterProvider with ChangeNotifier {
  String? _userNameFilter;

  String? get userNameFilter => _userNameFilter;

  void setUserNameFilter(String? newName){
    _userNameFilter = newName;
  }

  void resetFilters(){
    _userNameFilter = null;
  }
}