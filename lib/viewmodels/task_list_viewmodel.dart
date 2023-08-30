
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
  Map<String, List<Task>> get tasks => _tasks;


  int page = 0;
  int size = 10;

  void clearLists() {
    for (var key in _tasks.keys) {
      _tasks[key]?.clear();
    }
  }

  Future<List<Task>?> initializeTasks(BuildContext context, String status, String? user) async {
   return await fetchTasksFromUser(context, status, user);
  }

  Future<List<Task>?> fetchTasksFromUser(BuildContext context, String status, String? user) async {
    final token = context.read<UserProvider>().getToken;
    String? userName;
    if (user == null) {
      userName = context
          .read<UserProvider>()
          .userName;
    } else {
      userName = user;
    }
    try {

      final responseListTask = await _taskService.getTasks(token!,userName!,page,size,status);
      _tasks[status] = responseListTask!;
      notifyListeners();
      return responseListTask;
    } catch (error) {
      print(error);
      throw Exception('Error al obtener los datos');
    }
  }

  Future<bool> deleteTask(BuildContext context, int id) async {
    final token = context.read<UserProvider>().getToken;
    try {
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
      print(error);
      throw Exception('Error al eliminar la tarea');
    }
  }

  Future<Task?> fetchTask(token, int idTask) async {
    try {

      final responseTask = await _taskService.fetchTask(token, idTask);
      if (responseTask != null) {
        notifyListeners();
        return responseTask;
      } else {
        if (kDebugMode) {
          print('No se pudieron traer datos');
        }
        return null;
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      throw Exception('Error al obtener los datos');
    }
  }

  Future<bool> updateTask(String token, int idTask, Map<String, dynamic> body)  async {

    try {
      final response = await _taskService.updateTask(token, idTask, body);
      if (response) {
        print('Tarea ha sido actualizada correctamente');
        notifyListeners();
        return true;
      } else {
        print('No se pudieron traer datos');
        return false;
      }
    } catch (error) {
      print(error);
      throw Exception('Error al obtener los datos');
    }
  }

  Future<bool> createTask(String token, Map<String, dynamic> body) async {

    try {
      final response = await _taskService.createTask(token, body);
      if (response) {
        print('Tarea ha sido creada correctamente');
        notifyListeners();
        return true;
      } else {
        print('No se pudieron traer datos');
        return false;
      }
    } catch (error) {
      print(error);
      throw Exception('Error al obtener los datos');
    }
  }

}
