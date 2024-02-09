import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/auth_data.dart';
import '../models/user_info.dart';

class AuthResult {
  final AuthData? authData;
  final int statusCode;

  AuthResult(this.authData, this.statusCode);
}

class AuthService {
  final String baseUrl;

  AuthService({String? baseUrl})
      : baseUrl = baseUrl ?? dotenv.get('API_TASKS_URL', fallback: 'NOT_FOUND');

  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization':
          "Basic ${dotenv.get('API_AUTHORIZATION', fallback: 'NOT_FOUND')}",
    };
  }

  Map<String, String> _getHeaders_forgotpass() {
    return {
      'Content-Type': 'application/json',
      'Authorization':
          "Bearer  ${dotenv.get('API_AUTHORIZATION', fallback: 'NOT_FOUND')}",
    };
  }

  Future<AuthResult> fetchAuth(String username, String password) async {
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
        final authData = AuthData.fromJson(jsonResponse);
        return AuthResult(authData, response.statusCode);
      } else {
        return AuthResult(null, response.statusCode);
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error en fetchAuth: $error');
      }
      rethrow;
    }
  }

  Future<bool> recoverPassword(String email, Map<String, dynamic> body) async {
    try {
      Map<String, String> headersAlt = {
        'Content-Type': 'application/json',
        'Authorization': "Bearer ${dotenv.get('API_AUTHORIZATION', fallback: 'NOT_FOUND')}",
      };

      final String jsonBody = jsonEncode(body);
      String url =
          "${dotenv.get('GATEWAY_API_BASE', fallback: 'NOT_FOUND')}/usuarios/forgot-password";
      final response =
          await http.post(Uri.parse(url), headers: headersAlt, body: jsonBody);

      final codigo = response.statusCode;
      print('code: $codigo');

      if (response.statusCode == 201) {
        print('Se ha enviado mail de recuperacion de contrasena');
        return true;
      } else {
        print('No se pudieron traer datos');
        return false;
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error in recoverPassword: $error');
      }
      rethrow;
    }
  }

  Future<UserInfo?> getUserRole(String token) async {
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': "Bearer $token",
      };

      String url =
          "${dotenv.get('GATEWAY_API_BASE', fallback: 'NOT_FOUND')}/usuarios/me";
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return UserInfo.fromJson(jsonResponse);
      } else {
        return null;
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error en getUserRole: $error');
      }
      rethrow;
    }
  }

  Future<AuthResult> refreshAuthData(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse(dotenv.get('API_AUTH', fallback: 'NOT_FOUND')),
        headers: _getHeaders(),
        body: {'grant_type': 'refresh_token', 'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final authData = AuthData.fromJson(jsonResponse);
        return AuthResult(authData, response.statusCode);
      } else {
        return AuthResult(null, response.statusCode);
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error en refreshAccessToken: $error');
      }
      rethrow;
    }
  }
}
