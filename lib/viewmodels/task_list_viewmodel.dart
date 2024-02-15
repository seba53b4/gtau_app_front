import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gtau_app_front/models/task.dart';
import 'package:gtau_app_front/services/task_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/user_provider.dart';
import '../utils/common_utils.dart';

class TaskListViewModel extends ChangeNotifier {
  final TaskService _taskService = TaskService();
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

  void setPage(int newPage) {
    page = newPage;
  }

  void clearListByStatus(String status) {
    _tasks[status]?.clear();
    page = 0;
  }

  Future<List<Task>?> initializeTasks(
      BuildContext context, String status, String? user) async {
    return await fetchTasksFromUser(context, status, user);
  }

  Future<List<Task>?> nextPageListByStatus(
      BuildContext context, String status, String? user) async {
    return await fetchNextPageTasksFromUser(context, status, user);
  }

  Future<List<Task>?> nextPageFilteredListByStatus(BuildContext context,
      String status, String? user, String encodedBody) async {
    return await fetchNextPageFilteredTasksFromUser(
        context, status, user, encodedBody);
  }

  Future<List<Task>?> fetchTasksFromUser(
      BuildContext context, String status, String? user) async {
    final token = context.read<UserProvider>().getToken;
    String? userName;
    if (user == null) {
      userName = context.read<UserProvider>().userName;
    } else {
      userName = user;
    }
    try {
      _SetIsLoadingPrefValue(true);
      _error = false;
      _isLoading = true;

      notifyListeners();
      final responseListTask =
          await _taskService.getTasks(token!, userName!, page, size, status);

      _tasks[status] = responseListTask!;

      return responseListTask;
    } catch (error) {
      _error = true;
      printOnDebug(error);
      _SetIsLoadingPrefValue(false);
      throw Exception('Error al obtener los datos');
    } finally {
      _isLoading = false;
      _SetIsLoadingPrefValue(false);
      page++;
      notifyListeners();
    }
  }

  _SetActualPage(int page) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt("actual_page", page);
  }

  Future<List<Task>?> fetchNextPageTasksFromUser(
      BuildContext context, String status, String? user) async {
    final token = context.read<UserProvider>().getToken;
    String? userName;
    if (user == null) {
      userName = context.read<UserProvider>().userName;
    } else {
      userName = user;
    }
    try {
      _isLoading = true;
      _error = false;

      final responseListTask =
          await _taskService.getTasks(token!, userName!, page, size, status);

      _tasks[status]?.addAll(responseListTask!);
      final size_list = responseListTask?.length ?? 0;
      if (size_list > 0) {
        page++;
      }
      _SetActualPage(page);

      return responseListTask;
    } catch (error) {
      _error = true;
      printOnDebug(error);
      throw Exception('Error al obtener los datos');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Task>?> fetchNextPageFilteredTasksFromUser(BuildContext context,
      String status, String? user, String encodedBody) async {
    final token = context.read<UserProvider>().getToken;
    String? userName;
    if (user == null) {
      userName = context.read<UserProvider>().userName;
    } else {
      userName = user;
    }
    try {
      _isLoading = true;
      _error = false;
      Map<String, dynamic> body = json.decode(encodedBody);

      final responseListTask =
          await _taskService.searchTasks(token!, body, page, size);

      _tasks[status]?.addAll(responseListTask!);
      final size_list = responseListTask?.length ?? 0;
      if (size_list > 0) {
        page++;
      }
      _SetActualPage(page);

      return responseListTask;
    } catch (error) {
      _error = true;
      printOnDebug(error);
      throw Exception('Error al obtener los datos');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Task>?> fetchTasksFromFilters(
      BuildContext context, String status, Map<String, dynamic> body) async {
    final token = context.read<UserProvider>().getToken;
    try {
      _isLoading = true;
      _SetIsLoadingPrefValue(true);
      _error = false;
      notifyListeners();
      String encodedMap = json.encode(body);
      _SetBodyPrefValue(encodedMap);

      final responseListTask =
          await _taskService.searchTasks(token!, body, page, size);

      _tasks[status] = responseListTask!;

      return responseListTask;
    } catch (error) {
      _error = true;
      _SetIsLoadingPrefValue(false);
      printOnDebug(error);
      throw Exception('Error al obtener los datos');
    } finally {
      _isLoading = false;
      _SetIsLoadingPrefValue(false);
      page++;
      notifyListeners();
    }
  }

  Future<bool> deleteTask(String token, int id) async {
    try {
      _isLoading = true;
      _error = false;
      notifyListeners();
      final response = await _taskService.deleteTask(token, id);

      if (response) {
        printOnDebug('Tarea ha sido eliminada correctamente');
        return true;
      } else {
        printOnDebug('No se pudo eliminar la tarea');
        return false;
      }
    } catch (error) {
      _error = true;
      printOnDebug(error);
      throw Exception('Error al eliminar la tarea');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Task?> fetchTask(token, int idTask) async {
    try {
      _SetIsLoadingPrefValue(true);
      _isLoading = true;
      _error = false;
      notifyListeners();
      final responseTask = await _taskService.fetchTask(token, idTask);
      if (responseTask != null) {
        return responseTask;
      } else {
        printOnDebug('No se pudieron traer datos');

        _error = true;
        return null;
      }
    } catch (error) {
      _SetIsLoadingPrefValue(false);
      _error = true;
      printOnDebug(error);
      throw Exception('Error al obtener los datos');
    } finally {
      _SetIsLoadingPrefValue(false);
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateTask(
      String token, int idTask, Map<String, dynamic> body) async {
    try {
      _SetIsLoadingPrefValue(true);
      _isLoading = true;
      _error = false;
      notifyListeners();
      final response = await _taskService.updateTask(token, idTask, body);
      if (response) {
        printOnDebug('Tarea ha sido actualizada correctamente');
        notifyListeners();
        return true;
      } else {
        _error = true;
        printOnDebug('No se pudieron traer datos');
        return false;
      }
    } catch (error) {
      _SetIsLoadingPrefValue(false);
      _error = true;
      printOnDebug(error);
      throw Exception('Error al obtener los datos');
    } finally {
      _SetIsLoadingPrefValue(false);
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createTask(String token, Map<String, dynamic> body) async {
    try {
      _isLoading = true;
      _error = false;
      notifyListeners();
      final response = await _taskService.createTask(token, body);
      if (response) {
        printOnDebug('Tarea ha sido creada correctamente');
        notifyListeners();
        return true;
      } else {
        _error = true;
        printOnDebug('No se pudieron traer datos');
        return false;
      }
    } catch (error) {
      _error = true;
      printOnDebug(error);
      throw Exception('Error al obtener los datos');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
