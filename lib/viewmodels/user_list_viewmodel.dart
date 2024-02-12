import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gtau_app_front/models/user_data.dart';
import 'package:gtau_app_front/services/user_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/user_provider.dart';

class UserListViewModel extends ChangeNotifier {
  final UserService _userService = UserService();
  final Map<String, List<UserData>> _users = {"ACTIVE": []};

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  bool _error = false;

  bool get error => _error;

  Map<String, List<UserData>> get users => _users;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  int page = 0;
  int size = kIsWeb ? 12 : 10;

  void _SetBodyPrefValue(String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("bodyFiltered", value);
  }

  void _SetIsLoadingPrefValue(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("is_loading", value);
  }

  Future<String> _GetBodyPrefValue() async {
    final SharedPreferences prefs = await _prefs;
    return (prefs.getString("bodyFiltered") ?? "");
  }

  void clearLists() {
    for (var key in _users.keys) {
      _users[key]?.clear();
    }
  }

  void setPage(int newPage) {
    page = newPage;
  }

  void clearListByStatus(String status) {
    _users[status]?.clear();
  }

  Future<List<UserData>?> initializeUsers(
      BuildContext context, String status, String? user) async {
    return await fetchUsers(context, user);
  }

  Future<List<UserData>?> fetchUsers(BuildContext context, String? user) async {
    final token = context.read<UserProvider>().getToken;
    try {
      _SetIsLoadingPrefValue(true);
      _error = false;
      _isLoading = true;

      notifyListeners();
      final responseListUsers = await _userService.getUsers(token!);

      _users["ACTIVE"] = responseListUsers!;

      return responseListUsers;
    } catch (error) {
      _error = true;
      print(error);
      _SetIsLoadingPrefValue(false);
      throw Exception('Error al obtener los datos');
    } finally {
      _isLoading = false;
      _SetIsLoadingPrefValue(false);
      page++;
      notifyListeners();
    }
  }

  Future<List<String>?> fetchUsernames(BuildContext context) async {
    final token = context.read<UserProvider>().getToken;
    try {
      _SetIsLoadingPrefValue(true);
      _error = false;
      _isLoading = true;

      //notifyListeners();
      final responseListUsers = await _userService.getUsernames(token!);

      return responseListUsers;
    } catch (error) {
      _error = true;
      print(error);
      _SetIsLoadingPrefValue(false);
      throw Exception('Error al obtener los datos');
    } finally {
      _isLoading = false;
      _SetIsLoadingPrefValue(false);
      page++;
      notifyListeners();
    }
  }

  Future<UserData?> fetchUser(token, String idUser) async {
    try {
      _SetIsLoadingPrefValue(true);
      _isLoading = true;
      _error = false;
      //notifyListeners();
      final responseTask = await _userService.getUserById(token, idUser);
      if (responseTask != null) {
        return responseTask;
      } else {
        if (kDebugMode) {
          print('No se pudieron traer datos');
        }
        _error = true;
        return null;
      }
    } catch (error) {
      _SetIsLoadingPrefValue(false);
      _error = true;
      if (kDebugMode) {
        print(error);
      }
      throw Exception('Error al obtener los datos');
    } finally {
      _SetIsLoadingPrefValue(false);
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<UserData>?> fetchUserByFilter(token, String? username,
      String? email, String? firstName, String? lastName, String? role) async {
    try {
      _SetIsLoadingPrefValue(true);
      _isLoading = true;
      _error = false;
      notifyListeners();

      final responseListUsers = await _userService.searchUsers(
          token, username, email, firstName, lastName, role);
      _users["ACTIVE"] = responseListUsers!;

      return responseListUsers;
    } catch (error) {
      _SetIsLoadingPrefValue(false);
      _error = true;
      if (kDebugMode) {
        print(error);
      }
      throw Exception('Error al obtener los datos');
    } finally {
      _SetIsLoadingPrefValue(false);
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<UserData?> fetchUserByUsername(token, String? username) async {
    try {
      _isLoading = true;
      _error = false;
      notifyListeners();
      final responseListUsers = await _userService.searchUsers(
          token, username, null, null, null, null);

      return responseListUsers?.first;
    } catch (error) {
      _error = true;
      if (kDebugMode) {
        print(error);
      }
      throw Exception('Error al obtener los datos: fetchUserByUsername');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteUser(String token, String id) async {
    try {
      _isLoading = true;
      _error = false;
      notifyListeners();
      final response = await _userService.deleteUser(token, id);

      if (response) {
        print('Usuario ha sido eliminado correctamente');
        return true;
      } else {
        print('No se pudo eliminar el usuario');
        return false;
      }
    } catch (error) {
      _error = true;
      print(error);
      throw Exception('Error al eliminar el usuario');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUser(
      String token, String idUser, Map<String, dynamic> body) async {
    try {
      _SetIsLoadingPrefValue(true);
      _isLoading = true;
      _error = false;
      notifyListeners();
      final response = await _userService.updateUser(token, idUser, body);
      if (response) {
        print('Usuario ha sido actualizada correctamente');
        notifyListeners();
        return true;
      } else {
        _error = true;
        print('No se pudieron traer datos');
        return false;
      }
    } catch (error) {
      _SetIsLoadingPrefValue(false);
      _error = true;
      print(error);
      throw Exception('Error al obtener los datos');
    } finally {
      _SetIsLoadingPrefValue(false);
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createUser(String token, Map<String, dynamic> body) async {
    try {
      _isLoading = true;
      _error = false;
      notifyListeners();
      final response = await _userService.createUser(token, body);
      if (response) {
        notifyListeners();
        return true;
      } else {
        _error = true;
        print('No se pudieron traer datos');
        return false;
      }
    } catch (error) {
      _error = true;
      print(error);
      throw Exception('Error al obtener los datos');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
