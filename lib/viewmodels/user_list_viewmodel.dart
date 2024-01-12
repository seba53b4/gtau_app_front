import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gtau_app_front/models/task.dart';
import 'package:gtau_app_front/services/task_service.dart';
import 'package:gtau_app_front/services/user_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/user_provider.dart';

class UserListViewModel extends ChangeNotifier {
  final TaskService _taskService = TaskService();
  final UserService _userService = UserService();
  final Map<String, List<Task>> _tasks = {
    "DOING": [],
    "DONE": [],
    "PENDING": [],
    "BLOCKED": []
  };

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  bool _error = false;

  bool get error => _error;

  Map<String, List<Task>> get tasks => _tasks;
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
    for (var key in _tasks.keys) {
      _tasks[key]?.clear();
    }
  }

  void setPage(int newPage){
    page=newPage;
  }

  void clearListByStatus(String status) {
    _tasks[status]?.clear();
    page = 0;
  }

  
  
  

  Future<bool> deleteUser(String token, int id) async {
    try {
      _isLoading = true;
      _error = false;
      notifyListeners();
      final response = await _taskService.deleteTask(token, id);

      if (response) {
        print('Tarea ha sido eliminada correctamente');
        return true;
      } else {
        print('No se pudo eliminar la tarea');
        return false;
      }
    } catch (error) {
      _error = true;
      print(error);
      throw Exception('Error al eliminar la tarea');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  
  Future<bool> updateUser(
      String token, int idTask, Map<String, dynamic> body) async {
    try {
      _SetIsLoadingPrefValue(true);
      _isLoading = true;
      _error = false;
      notifyListeners();
      final response = await _taskService.updateTask(token, idTask, body);
      if (response) {
        print('Tarea ha sido actualizada correctamente');
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
