import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gtau_app_front/models/task.dart';
import 'package:gtau_app_front/services/task_service.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';

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

  int page = 0;
  int size = 10;

  void clearLists() {
    for (var key in _tasks.keys) {
      _tasks[key]?.clear();
    }
  }

  void resetError() {
    _error = false;
  }

  void clearListByStatus(String status) {
    _tasks[status]?.clear();
  }

  Future<List<Task>?> initializeTasks(
      BuildContext context, String status, String? user) async {
    return await fetchTasksFromUser(context, status, user);
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
      _isLoading = true;
      _error = false;
      notifyListeners();

      final responseListTask =
          await _taskService.getTasks(token!, userName!, page, size, status);

      _tasks[status] = responseListTask!;

      return responseListTask;
    } catch (error) {
      _error = true;
      print(error);
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
      _error = false;
      notifyListeners();

      final responseListTask =
          await _taskService.searchTasks(token!, body, page, size);

      _tasks[status] = responseListTask!;

      return responseListTask;
    } catch (error) {
      _error = true;
      print(error);
      throw Exception('Error al obtener los datos');
    } finally {
      _isLoading = false;
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

  Future<Task?> fetchTask(token, int idTask) async {
    try {
      _isLoading = true;
      _error = false;
      notifyListeners();
      final responseTask = await _taskService.fetchTask(token, idTask);
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
      _error = true;
      if (kDebugMode) {
        print(error);
      }
      throw Exception('Error al obtener los datos');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateTask(
      String token, int idTask, Map<String, dynamic> body) async {
    try {
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
      _error = true;
      print(error);
      throw Exception('Error al obtener los datos');
    } finally {
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
        print('Tarea ha sido creada correctamente');
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
