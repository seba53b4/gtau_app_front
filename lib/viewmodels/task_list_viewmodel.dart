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
      notifyListeners();

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

  Future<bool> deleteTask(BuildContext context, int id) async {
    final token = context.read<UserProvider>().getToken;
    try {
      _isLoading = true;
      _error = false;
      notifyListeners();
      final response = await _taskService.deleteTask(token!, id);

      if (response) {
        print('Tarea ha sido eliminada correctamente');
        notifyListeners();
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
        notifyListeners();
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

  Future<List<String>> fetchTaskImages(token, int idTask) async {
    try {
      _isLoading = true;
      _error = false;
      notifyListeners();
      final List<String> responseTask =
          await _taskService.fetchTaskImages(token, idTask);
      if (responseTask != []) {
        notifyListeners();
        return responseTask;
      } else {
        _error = true;
        if (kDebugMode) {
          print('No se pudieron traer datos');
        }
        return [];
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

  uploadImage(String token, int id, String path) {
    if (kIsWeb) {
      _taskService.putBase64Images(token, id, path);
    } else {
      _taskService.putMultipartImages(token, id, path);
    }
  }

  Future<bool> deleteImage(String token, int id, String path) {
    return _taskService.deleteTaskImage(token, id, path);
  }
}
