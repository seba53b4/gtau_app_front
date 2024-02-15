import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gtau_app_front/models/task.dart';
import 'package:http/http.dart' as http;

import '../utils/common_utils.dart';

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
        return parseTaskListResponse(response);
      } else {
        printOnDebug('Error getTasks re null');
        return null;
      }
    } catch (error) {
      printOnDebug('Error in getTasks: $error');

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
      printOnDebug('Error in deleteTask: $error');
      rethrow;
    }
  }

  Future<Task?> fetchTask(token, int idTask) async {
    try {
      final url = Uri.parse('$baseUrl/$idTask');
      final response = await http.get(url, headers: _getHeaders(token));
      if (response.statusCode == 200) {
        final taskData = json.decode(response.body);
        var position = taskData['position'];
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
            registers: _parseIntListToCircleIdList(taskData['registros']),
            lots: _parseIntListToPolylineIdList(taskData['parcelas']),
            position: position != null && position['latitud'] != null
                ? LatLng(position['latitud'], position['longitud'])
                : const LatLng(0, 0));
      } else {
        printOnDebug('No se pudieron traer datos');
        return null;
      }
    } catch (error) {
      printOnDebug('Error in fetchTask: $error');
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
        printOnDebug('Tarea ha sido actualizada correctamente');
        return true;
      } else {
        printOnDebug('Error en update de tarea');
        return false;
      }
    } catch (error) {
      printOnDebug('Error in updateTask: $error');

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
        printOnDebug('Tarea ha sido creada correctamente');
        return true;
      } else {
        printOnDebug('No se pudieron traer datos');
        return false;
      }
    } catch (error) {
      printOnDebug('Error in createTask: $error');

      rethrow;
    }
  }

  Future<List<Task>?> searchTasks(
      String token, Map<String, dynamic> body, int page, int size) async {
    try {
      final url = Uri.parse('$baseUrl/search?page=$page&size=$size');
      final String jsonBody = jsonEncode(body);
      final response =
          await http.post(url, headers: _getHeaders(token), body: jsonBody);

      if (response.statusCode == 200) {
        return parseTaskListResponse(response);
      } else {
        printOnDebug('No se pudieron traer datos');
        return null;
      }
    } catch (error) {
      printOnDebug('Error in createTask: $error');

      rethrow;
    }
  }

  parseTaskListResponse(http.Response response) {
    final data = json.decode(response.body);
    final content = data['content'];
    return content.map<Task>((taskData) {
      var position = taskData['position'];
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
          registers: _parseIntListToCircleIdList(taskData['registros']),
          lots: _parseIntListToPolylineIdList(taskData['parcelas']),
          position: position != null && position['latitud'] != null
              ? LatLng(position['latitud'], position['longitud'])
              : const LatLng(0, 0));
    }).toList();
  }

  Future<List<String>> fetchTaskInformes(token, int idTask) async {
    try {
      final url = Uri.parse('$baseUrl/$idTask/informes');
      final response = await http.get(url, headers: _getHeaders(token));
      if (response.statusCode == 200) {
        List<dynamic> decode = json.decode(response.body) as List<dynamic>;
        return decode.map((e) => e["informe"].toString()).toList();
      } else {
        printOnDebug('No se pudieron traer datos');
        return [];
      }
    } catch (error) {
      printOnDebug('Error in fetchTaskInformes: $error');
      rethrow;
    }
  }

  Future<String> putBase64Informes(
      String token, int id, Map<String, dynamic> informe) async {
    try {
      // Uri uri = Uri.parse(path);
      // String basename = p.basename(uri.path);

      // Map<String, String> informeEncode = await informeToBase64(path);
      var content = 'application/pdf';
      var base64 = informe['base64'];
      var fileName = informe['fileName'];
      final Map<String, dynamic> body = {
        "informe": "$content,$base64",
        "name": "$fileName"
      };

      final String jsonBody = jsonEncode(body);
      final url = Uri.parse('$baseUrl/$id/informe/v2');
      final response =
          await http.post(url, headers: _getHeaders(token), body: jsonBody);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        //Cuando ingresa a la galeria la imagen se renderiza de todas formas, no es necesario hacer nada aca.
        var informe = jsonResponse['informe'];
        return informe;
      } else {
        return '';
      }
    } catch (error) {
      printOnDebug('Error al guardar informes: $error');

      rethrow;
    }
  }

  Future<bool> deleteTaskInforme(String token, int id, String path) async {
    try {
      var fileName = path.split("/").last;
      final Map<String, dynamic> body = {"name": fileName};

      final String jsonBody = jsonEncode(body);
      final url = Uri.parse('$baseUrl/$id/informe');
      final response =
          await http.delete(url, headers: _getHeaders(token), body: jsonBody);
      if (response.statusCode == 200) {
        final bool jsonResponse = json.decode(response.body);

        return jsonResponse;
      } else {
        return false;
      }
    } catch (error) {
      printOnDebug('Error al borrar informe: $error');
      rethrow;
    }
  }
}
