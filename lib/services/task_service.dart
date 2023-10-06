import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gtau_app_front/models/task.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;

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
        //print('Error getTasks no null,  statusCode:${response.statusCode} ${response.body}');
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

  Future<List<String>> fetchTaskImages(token, int idTask) async {
    try {
      final url = Uri.parse('$baseUrl/$idTask/images');
      final response = await http.get(url, headers: _getHeaders(token));
      if (response.statusCode == 200) {
        List<dynamic> decode = json.decode(response.body) as List<dynamic>;
        return decode.map((e) => e["image"].toString()).toList();
      } else {
        if (kDebugMode) {
          print('No se pudieron traer datos');
        }
        return [];
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error in fetchTaskImages: $error');
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

  Future<List<String>?> putBase64Images(
      String token, int id, String path) async {
    try {
      Uri uri = Uri.parse(path);
      String basename = p.basename(uri.path);

      Map<String, String> imageEncode = await imageToBase64(path);
      var extension = imageEncode['ext'];
      var content = imageEncode['content'];
      var base64 = imageEncode['base64'];
      final Map<String, dynamic> body = {
        "image": "$content,$base64",
        "name": "$basename.$extension"
      };

      final String jsonBody = jsonEncode(body);
      final url = Uri.parse('$baseUrl/$id/image/v2');
      final response =
          await http.post(url, headers: _getHeaders(token), body: jsonBody);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        //Cuando ingresa a la galeria la imagen se renderiza de todas formas, no es necesario hacer nada aca.
        var image = jsonResponse['image'];
        var id = jsonResponse['inspectionTaskId'];

        return jsonResponse.entries.map<String>((entry) {
          return "${entry.key}: ${entry.value}"; //Agrego esto por aca solo para que no salte error
        }).toList();
      } else {
        return null;
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error al guardar imagenes: $error');
      }
      rethrow;
    }
  }

  Future<Map<String, String>> imageToBase64(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      String content = response.headers['content-type'].toString();
      String ext = content.split('/').last;
      final List<int> imageBytes = response.bodyBytes;
      final String base64String = base64Encode(imageBytes);
      return {
        "ext": ext,
        "base64": base64String,
        "content": content,
      };
    } else {
      throw Exception('No se pudo cargar la imagen desde la URL: $imageUrl');
    }
  }

  Future<bool> putMultipartImages(String token, int id, String path) async {
    try {
      final url = Uri.parse('$baseUrl/$id/image');
      var request = http.MultipartRequest("POST", url);
      request.headers.addAll(_getHeaders(token));
      request.files.add(await http.MultipartFile.fromPath('image', path,
          contentType: MediaType('image', 'jpg')));
      var response = await request.send();

      return response.statusCode == 200;
    } catch (error) {
      if (kDebugMode) {
        print('Error al guardar imagenes: $error');
      }
      rethrow;
    }
  }
}
