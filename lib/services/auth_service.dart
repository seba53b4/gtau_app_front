import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/auth_data.dart';

class AuthService {
  final String baseUrl;

  AuthService({String? baseUrl}) : baseUrl = baseUrl ?? dotenv.get('API_TASKS_URL', fallback: 'NOT_FOUND');

  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': "Basic ${dotenv.get('API_AUTHORIZATION', fallback: 'NOT_FOUND')}",
    };
  }

  Future<AuthData?> fetchAuth(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(dotenv.get('API_AUTH', fallback: 'NOT_FOUND')),
        headers: _getHeaders(),
        body: {
          'grant_type': 'password',
          'username': username,
          'password': password,
          'scope': 'openid profile roles',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return AuthData.fromJson(jsonResponse);
      } else {
        throw Exception('Error en la autenticación');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error en fetchAuth: $error');
      }
      rethrow;
    }
  }

}
