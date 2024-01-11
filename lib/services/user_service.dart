import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gtau_app_front/models/task.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;

class UserService {
  final String baseUrl;

  UserService({String? baseUrl})
      : baseUrl = baseUrl ?? dotenv.get('API_USERS_URL', fallback: 'NOT_FOUND');

  Map<String, String> _getHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<bool> deleteUser(String token, int id) async {
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

  Future<bool> createUser(String token, Map<String, dynamic> body) async {
    try {
      final String jsonBody = jsonEncode(body);
      final url = Uri.parse(baseUrl);
      final response =
          await http.post(url, headers: _getHeaders(token), body: jsonBody);

      if (response.statusCode == 201) {
        print('Usuario ha sido creado correctamente');
        return true;
      } else {
        print('No se pudieron traer datos');
        return false;
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error in createUser: $error');
      }
      rethrow;
    }
  }

  
}
