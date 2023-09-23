import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gtau_app_front/models/task.dart';
import 'package:http/http.dart' as http;

class TaskService {
  final String baseUrl;

  TaskService({String? baseUrl})
      : baseUrl = baseUrl ?? dotenv.get('API_TASKS_URL', fallback: 'NOT_FOUND');

  Map<String, String> _getHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Task>?> getTasks(
      String token, String user, int page, int size, String status) async {
    try {
      String userByType =
          dotenv.get('BY_USER_N_TYPE_URL', fallback: 'NOT_FOUND');
      final url = Uri.parse(
          '$baseUrl/$userByType?page=$page&size=$size&user=$user&status=$status');
      final response = await http.get(url, headers: _getHeaders(token));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['content'];
        return content.map<Task>((taskData) {
          return Task(
              id: taskData['id'],
              status: taskData['status'],
              inspectionType: taskData['inspectionType'],
              workNumber: taskData['workNumber'],
              addDate: DateTime.parse(taskData['addDate']),
              applicant: taskData['applicant'],
              location: taskData['location'],
              description: taskData['description'],
              releasedDate: taskData['releasedDate'] != null
                  ? DateTime.parse(taskData['releasedDate'])
                  : null,
              user: taskData['user'],
              length: taskData['length'],
              material: taskData['material'],
              observations: taskData['observations'],
              conclusions: taskData['conclusions'],
              sections: _parseIntListToPolylineIdList(taskData['tramos']),
              catchments: _parseIntListToCircleIdList(taskData['captaciones']),
              registers: _parseIntListToCircleIdList(taskData['registros']));
        }).toList();
      } else {
        print('Error getTasks re null');
        return null;
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error in getTasks: $error');
      }
      rethrow;
    }
  }

  Set<PolylineId> _parseIntListToPolylineIdList(dynamic sections) {
    List<int> sectionsList = List<int>.from(sections);
    Set<PolylineId> returnSections = {};

    for (int section in sectionsList) {
      String sectionString = section.toString();
      PolylineId polylineId = PolylineId(sectionString);
      returnSections.add(polylineId);
    }
    return returnSections;
  }

  Set<CircleId> _parseIntListToCircleIdList(dynamic catchments) {
    List<int> catchmentList = List<int>.from(catchments);
    Set<CircleId> returnCatchments = {};

    for (int section in catchmentList) {
      String sectionString = section.toString();
      CircleId circleId = CircleId(sectionString);
      returnCatchments.add(circleId);
    }
    return returnCatchments;
  }

  Future<bool> deleteTask(String token, int id) async {
    try {
      final url = Uri.parse('$baseUrl/$id');
      final response = await http.delete(url, headers: _getHeaders(token));
      return response.statusCode == 204;
    } catch (error) {
      if (kDebugMode) {
        print('Error in deleteTask: $error');
      }
      rethrow;
    }
  }

  Future<Task?> fetchTask(token, int idTask) async {
    try {
      final url = Uri.parse('$baseUrl/$idTask');
      final response = await http.get(url, headers: _getHeaders(token));
      if (response.statusCode == 200) {
        final taskData = json.decode(response.body);

        return Task(
            id: taskData['id'],
            status: taskData['status'],
            inspectionType: taskData['inspectionType'],
            workNumber: taskData['workNumber'],
            addDate: DateTime.parse(taskData['addDate']),
            applicant: taskData['applicant'],
            location: taskData['location'],
            description: taskData['description'],
            releasedDate: taskData['releasedDate'] != null
                ? DateTime.parse(taskData['releasedDate'])
                : null,
            user: taskData['user'],
            length: taskData['length'],
            material: taskData['material'],
            observations: taskData['observations'],
            conclusions: taskData['conclusions'],
            sections: _parseIntListToPolylineIdList(taskData['tramos']),
            catchments: _parseIntListToCircleIdList(taskData['captaciones']),
            registers: _parseIntListToCircleIdList(taskData['registros']));
      } else {
        if (kDebugMode) {
          print('No se pudieron traer datos');
        }
        return null;
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error in fetchTask: $error');
      }
      rethrow;
    }
  }

  Future<bool> updateTask(
      String token, int idTask, Map<String, dynamic> body) async {
    try {
      final url = Uri.parse('$baseUrl/$idTask');
      final String jsonBody = jsonEncode(body);
      final response =
          await http.put(url, headers: _getHeaders(token), body: jsonBody);
      if (response.statusCode == 200) {
        print('Tarea ha sido actualizada correctamente');
        return true;
      } else {
        print('Error en update de tarea');
        return false;
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error in updateTask: $error');
      }
      rethrow;
    }
  }

  Future<bool> createTask(String token, Map<String, dynamic> body) async {
    try {
      final String jsonBody = jsonEncode(body);
      final url = Uri.parse(baseUrl);
      final response =
          await http.post(url, headers: _getHeaders(token), body: jsonBody);

      if (response.statusCode == 201) {
        print('Tarea ha sido creada correctamente');
        return true;
      } else {
        print('No se pudieron traer datos');
        return false;
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error in createTask: $error');
      }
      rethrow;
    }
  }
}
