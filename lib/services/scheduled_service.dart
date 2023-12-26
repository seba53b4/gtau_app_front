import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gtau_app_front/models/scheduled/catchment_scheduled.dart';
import 'package:gtau_app_front/models/scheduled/register_scheduled.dart';
import 'package:gtau_app_front/models/scheduled/section_scheduled.dart';
import 'package:gtau_app_front/models/scheduled/task_scheduled.dart';
import 'package:http/http.dart' as http;

class ScheduledElements {
  List<RegisterScheduled> registers;
  List<SectionScheduled> sections;
  List<CatchmentScheduled> catchments;

  ScheduledElements({
    required this.registers,
    required this.sections,
    required this.catchments,
  });
}

class ScheduledService {
  final String baseUrl;

  ScheduledService({String? baseUrl})
      : baseUrl = baseUrl ??
            dotenv.get('API_SCHEDULED_TASKS_URL', fallback: 'NOT_FOUND');

  Map<String, String> _getHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<ScheduledElements?> fetchTaskScheduledEntities(
      String token, int idSchedTask) async {
    try {
      final url = Uri.parse('$baseUrl/$idSchedTask/entities');
      final response = await http.get(url, headers: _getHeaders(token));
      if (response.statusCode == 200) {
        final entities = json.decode(response.body);
        final entitiesRegister = entities['registroGeoJson'];
        final entitiesSection = entities['tramosGeoJson'];
        final entitiesCatchment = entities['captacionesGeoJson'];

        List<RegisterScheduled> registerList =
            entitiesRegister.map<RegisterScheduled>((registerData) {
          return RegisterScheduled.fromJson(json: registerData);
        }).toList();

        List<SectionScheduled> sectionList =
            entitiesSection.map<SectionScheduled>((sectionData) {
          return SectionScheduled.fromJson(json: sectionData);
        }).toList();

        List<CatchmentScheduled> catchmentList =
            entitiesCatchment.map<CatchmentScheduled>((catchmentData) {
          return CatchmentScheduled.fromJson(json: catchmentData);
        }).toList();

        return ScheduledElements(
          registers: registerList,
          sections: sectionList,
          catchments: catchmentList,
        );
      } else {
        if (kDebugMode) {
          print('No se pudieron traer datos');
        }
        return null;
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error in fetchTaskScheduledEntities: $error');
      }
      rethrow;
    }
  }

  Future<SectionScheduled?> fetchSectionScheduledById(
      String token, int scheduledId, int sectionId) async {
    try {
      final url = Uri.parse('$baseUrl/$scheduledId/tramo/$sectionId');
      final response = await http.get(
        url,
        headers: _getHeaders(token),
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return SectionScheduled.fromJson(json: jsonResponse, isFetch: true);
      } else {
        return null;
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error al obtener tramos: $error');
      }
      rethrow;
    }
  }

  Future<bool> updateSectionScheduled(String token, int scheduledId,
      int sectionId, Map<String, dynamic> body) async {
    try {
      final url = Uri.parse('$baseUrl/$scheduledId/tramo/$sectionId');
      final String jsonBody = jsonEncode(body);
      final response =
          await http.put(url, headers: _getHeaders(token), body: jsonBody);
      if (response.statusCode == 200) {
        print('Tramo en programada ha sido actualizado correctamente');
        return true;
      } else {
        print('Error al actualizar tramo en programada');
        return false;
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error in updateSectionScheduledById: $error');
      }
      rethrow;
    }
  }

  Future<RegisterScheduled?> fetchRegisterScheduledById(
      String token, int scheduledId, int registerId) async {
    try {
      final url = Uri.parse('$baseUrl/$scheduledId/registro/$registerId');
      final response = await http.get(
        url,
        headers: _getHeaders(token),
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return RegisterScheduled.fromJson(json: jsonResponse, isFetch: true);
      } else {
        return null;
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error al obtener registro en programada: $error');
      }
      rethrow;
    }
  }

  Future<bool> updateRegisterScheduled(String token, int scheduledId,
      int registerId, Map<String, dynamic> body) async {
    try {
      final url = Uri.parse('$baseUrl/$scheduledId/registro/$registerId');
      final String jsonBody = jsonEncode(body);
      final response =
          await http.put(url, headers: _getHeaders(token), body: jsonBody);
      if (response.statusCode == 200) {
        print('Registro en programada ha sido actualizado correctamente');
        return true;
      } else {
        print('Error al actualizar registro en programada');
        return false;
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error in updateRegisterScheduled: $error');
      }
      rethrow;
    }
  }

  Future<CatchmentScheduled?> fetchCatchmentScheduledById(
      String token, int scheduledId, int catchmentId) async {
    try {
      final url = Uri.parse('$baseUrl/$scheduledId/captacion/$catchmentId');
      final response = await http.get(
        url,
        headers: _getHeaders(token),
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return CatchmentScheduled.fromJson(json: jsonResponse, isFetch: true);
      } else {
        return null;
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error al obtener captacion en programada: $error');
      }
      rethrow;
    }
  }

  Future<bool> updateCatchmentScheduled(String token, int scheduledId,
      int catchmentId, Map<String, dynamic> body) async {
    try {
      final url = Uri.parse('$baseUrl/$scheduledId/captacion/$catchmentId');
      final String jsonBody = jsonEncode(body);
      final response =
          await http.put(url, headers: _getHeaders(token), body: jsonBody);
      if (response.statusCode == 200) {
        print('Captacion en programada ha sido actualizado correctamente');
        return true;
      } else {
        print('Error al actualizar captacion en programada');
        return false;
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error in updateCatchmentScheduled: $error');
      }
      rethrow;
    }
  }

  Future<List<TaskScheduled>?> getScheduledTasks(
      String token, int page, int size, String status) async {
    try {
      String userByType = dotenv.get('BY_STATUS_URL', fallback: 'NOT_FOUND');
      final url = Uri.parse(
          '$baseUrl/$userByType?page=$page&size=$size&status=$status');
      final response = await http.get(url, headers: _getHeaders(token));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['content'];
        return content.map<TaskScheduled>((taskScheduledData) {
          return TaskScheduled.fromJson(json: taskScheduledData);
        }).toList();
      } else {
        print('Error getScheduledTasks re null');
        return null;
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error in getScheduledTasks: $error');
      }
      rethrow;
    }
  }

  Future<bool> createScheduledTask(
      String token, Map<String, dynamic> body) async {
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

  Future<TaskScheduled?> fetchTaskScheduled(token, int scheduledId) async {
    try {
      final url = Uri.parse('$baseUrl/$scheduledId');
      final response = await http.get(url, headers: _getHeaders(token));
      if (response.statusCode == 200) {
        final taskData = json.decode(response.body);
        return TaskScheduled.fromJson(json: taskData);
      } else {
        if (kDebugMode) {
          print('No se pudieron traer datos');
        }
        return null;
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error in fetchTaskScheduled: $error');
      }
      rethrow;
    }
  }

  Future<bool> updateTaskScheduled(
      String token, int scheduledId, Map<String, dynamic> body) async {
    try {
      final url = Uri.parse('$baseUrl/$scheduledId');
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
        print('Error in updateTaskScheduled: $error');
      }
      rethrow;
    }
  }

  Future<bool> deleteTaskScheduled(String token, int scheduledId) async {
    try {
      final url = Uri.parse('$baseUrl/$scheduledId');
      final response = await http.delete(url, headers: _getHeaders(token));
      return response.statusCode == 204;
    } catch (error) {
      if (kDebugMode) {
        print('Error in deleteTaskScheduled: $error');
      }
      rethrow;
    }
  }

// Future<bool> createSheduledTask(
//     String token, Map<String, dynamic> body) async {
//   try {
//     final String jsonBody = jsonEncode(body);
//     final url = Uri.parse(baseUrl);
//     final response =
//         await http.post(url, headers: _getHeaders(token), body: jsonBody);
//
//     if (response.statusCode == 201) {
//       print('Tarea ha sido creada correctamente');
//       return true;
//     } else {
//       print('No se pudieron traer datos');
//       return false;
//     }
//   } catch (error) {
//     if (kDebugMode) {
//       print('Error in createTask: $error');
//     }
//     rethrow;
//   }
// }
}
