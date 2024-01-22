import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/scheduled/task_scheduled.dart';
import '../services/scheduled_service.dart';

class TaskListScheduledViewModel extends ChangeNotifier {
  final ScheduledService _scheduledService = ScheduledService();

  final Map<String, List<TaskScheduled>> _tasks = {
    "DOING": [],
    "DONE": [],
    "PENDING": [],
    "BLOCKED": []
  };

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  bool _error = false;

  bool get error => _error;

  Map<String, List<TaskScheduled>> get tasks => _tasks;
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

  Future<List<TaskScheduled>?> fetchScheduledTasks(
      String token, String status) async {
    try {
      _error = false;
      _isLoading = true;

      notifyListeners();
      final responseListTask =
          await _scheduledService.getScheduledTasks(token, page, size, status);

      _tasks[status] = responseListTask!;
      page++;
      return responseListTask;
    } catch (error) {
      _error = true;
      print(error);
      throw Exception('Error al obtener los datos fetchScheduledTasks');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<TaskScheduled>?> fetchNextPageTasksScheduled(
      String token, String status) async {
    try {
      _isLoading = true;
      _error = false;

      final responseListTask =
          await _scheduledService.getScheduledTasks(token, page, size, status);

      _tasks[status]?.addAll(responseListTask!);
      final size_list = responseListTask?.length ?? 0;
      if (size_list > 0) {
        page++;
      }
      _SetActualPage(page);

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

  Future<List<TaskScheduled>?> fetchTasksFromFilters(
      String token, String status, Map<String, dynamic> body) async {
    try {
      _isLoading = true;
      _SetIsLoadingPrefValue(true);
      _error = false;
      notifyListeners();
      String encodedMap = json.encode(body);
      _SetBodyPrefValue(encodedMap);

      final responseListTask =
          await _scheduledService.searchTasksScheduled(token!, body, page, size);
      
      final responseLength = responseListTask?.length;
      print('largo response: $responseLength');

      _tasks[status] = responseListTask!;

      return responseListTask;
    } catch (error) {
      _error = true;
      _SetIsLoadingPrefValue(false);
      print(error);
      throw Exception('Error al obtener los datos');
    } finally {
      _isLoading = false;
      _SetIsLoadingPrefValue(false);
      page++;
      notifyListeners();
    }
  }

  Future<List<TaskScheduled>?> fetchNextPageTasksFilteredScheduled(
      String token, String status, String encodedBody) async {
    try {
      _isLoading = true;
      _error = false;
      /*Map<String,dynamic> body = json.decode(encodedBody);*/

      //Se esta esperando que se implemente el search scheduled en el backend
      final responseListTask =
          await _scheduledService.getScheduledTasks(token, page, size, status);

      _tasks[status]?.addAll(responseListTask!);
      final size_list = responseListTask?.length ?? 0;
      if (size_list > 0) {
        page++;
      }
      _SetActualPage(page);

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

  Future<TaskScheduled?> createScheduledTask(
      String token, Map<String, dynamic> body) async {
    try {
      _isLoading = true;
      _error = false;
      notifyListeners();
      TaskScheduled? response =
          await _scheduledService.createScheduledTask(token, body);
      if (response != null) {
        notifyListeners();
        return response;
      } else {
        _error = true;
        print('No se pudieron traer datos');
        return null;
      }
    } catch (error) {
      _error = true;
      print(error);
      throw Exception('Error createScheduledTask');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<TaskScheduled?> fetchTaskScheduled(token, int scheduledId) async {
    try {
      _isLoading = true;
      _error = false;
      notifyListeners();
      final responseTask =
          await _scheduledService.fetchTaskScheduled(token, scheduledId);
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

  Future<bool> updateTaskScheduled(
      String token, int scheduledId, Map<String, dynamic> body) async {
    try {
      _isLoading = true;
      _error = false;
      notifyListeners();
      final response =
          await _scheduledService.updateTaskScheduled(token, scheduledId, body);
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
      throw Exception('Error al obtener los datos');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteTaskScheduled(String token, int scheduledId) async {
    try {
      _isLoading = true;
      _error = false;
      notifyListeners();
      final response =
          await _scheduledService.deleteTaskScheduled(token, scheduledId);

      if (response) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      _error = true;
      throw Exception('Error al eliminar la tarea');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  _SetActualPage(int page) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt("actual_page", page);
  }
}
