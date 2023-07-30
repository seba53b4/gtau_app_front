import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gtau_app_front/models/task.dart';
import 'package:gtau_app_front/services/task_service.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class TaskListViewModel extends ChangeNotifier {
  final TaskService _taskService = TaskService();
  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  int page = 0;
  int size = 10;

  Future<void> initializeTasks(BuildContext context, String status) async {
    await fetchTasksFromUser(context, status);
  }

  Future<bool> fetchTasksFromUser(BuildContext context, String status) async {
    final token = context.read<UserProvider>().getToken;
    final user = context.read<UserProvider>().userName;
    try {

      final response = await _taskService.getTasks(token!,user!,page,size,status);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['content'];

        _tasks = content.map<Task>((taskData) {
          return Task(
            id: taskData['id'],
            status: taskData['status'],
            inspectionType: taskData['inspectionType'],
            workNumber: taskData['workNumber'],
            addDate: DateTime.parse(taskData['addDate']),
            applicant: taskData['applicant'],
            location: taskData['location'],
            description: taskData['description'],
            releasedDate: taskData['releasedDate'] != null ? DateTime.parse(taskData['releasedDate']) : null,
            user: taskData['user'],
            length: taskData['length'],
            material: taskData['material'],
            observations: taskData['observations'],
            conclusions: taskData['conclusions'],
          );
        }).toList();

        notifyListeners();

        return true;
      } else {
        print('No se pudieron traer datos $status');
        return false;
      }
    } catch (error) {
      print(error);
      throw Exception('Error al obtener los datos');
    }
  }

  Future<bool> deleteTask(BuildContext context, int id) async {
    final token = context.read<UserProvider>().getToken;
    try {
      final response = await _taskService.deleteTask(token!, id);

      if (response.statusCode == 204) {
        print('Tarea ha sido eliminada correctamente');
        notifyListeners();
        return true;
      } else {
        print('No se pudo eliminar la tarea');
        print(response.statusCode);
        return false;
      }
    } catch (error) {
      print(error);
      throw Exception('Error al eliminar la tarea');
    }
  }

}
