import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gtau_app_front/models/scheduled/catchment_scheduled.dart';
import 'package:gtau_app_front/models/scheduled/register_scheduled.dart';
import 'package:gtau_app_front/models/scheduled/section_scheduled.dart';
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
          return RegisterScheduled.fromJson(registerData);
        }).toList();

        List<SectionScheduled> sectionList =
            entitiesSection.map<SectionScheduled>((sectionData) {
          return SectionScheduled.fromJson(json: sectionData);
        }).toList();

        List<CatchmentScheduled> catchmentList =
            entitiesCatchment.map<CatchmentScheduled>((catchmentData) {
          return CatchmentScheduled.fromJson(catchmentData);
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
