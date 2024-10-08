import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gtau_app_front/models/user_data.dart';
import 'package:http/http.dart' as http;

import '../utils/common_utils.dart';

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

  Map<String, String> _getHeadersAlt(String token) {
    return {
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<UserData>?> getUsers(String token) async {
    try {
      final url = Uri.parse(baseUrl);
      final response = await http.get(url, headers: _getHeaders(token));

      if (response.statusCode == 200) {
        return parseUserListResponse(response);
      } else {
        printOnDebug('Error getUsers re null');
        return null;
      }
    } catch (error) {
      printOnDebug('Error in getUsers: $error');

      rethrow;
    }
  }

  Future<List<String>?> getUsernames(String token) async {
    try {
      final url = Uri.parse(baseUrl);
      final response = await http.get(url, headers: _getHeaders(token));

      if (response.statusCode == 200) {
        return parseUsernamesListResponse(response);
      } else {
        printOnDebug('Error getUsernames re null');
        return null;
      }
    } catch (error) {
      printOnDebug('Error in getUsernames: $error');
      rethrow;
    }
  }

  Future<UserData?> getUserById(String token, String userId) async {
    try {
      final url = Uri.parse('$baseUrl/$userId');
      final response = await http.get(url, headers: _getHeaders(token));

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        return UserData(
            id: userData['id'],
            email: userData['email'],
            firstName: userData['firstName'],
            lastName: userData['lastName'],
            username: userData['username'],
            rol: userData['rol']);
      } else {
        printOnDebug('Error getUserByID re null');
        return null;
      }
    } catch (error) {
      printOnDebug('Error in getUserByID: $error');
      rethrow;
    }
  }

  Future<bool> deleteUser(String token, String id) async {
    try {
      final url = Uri.parse('$baseUrl/$id');
      final response = await http.delete(url, headers: _getHeadersAlt(token));
      return response.statusCode == 204;
    } catch (error) {
      printOnDebug('Error in deleteTask: $error');
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
        printOnDebug('Se ha creado el usuario');
        return true;
      } else {
        printOnDebug('No se pudieron traer datos');
        return false;
      }
    } catch (error) {
      printOnDebug('Error in createUser: $error');

      rethrow;
    }
  }

  Future<bool> updateUser(
      String token, String idUser, Map<String, dynamic> body) async {
    try {
      final String jsonBody = jsonEncode(body);
      final url = Uri.parse('$baseUrl/$idUser');
      final response =
          await http.put(url, headers: _getHeaders(token), body: jsonBody);

      if (response.statusCode == 200) {
        printOnDebug('Se ha actualizado el usuario');
        return true;
      } else {
        printOnDebug('No se pudieron traer datos');
        return false;
      }
    } catch (error) {
      printOnDebug('Error in updateUser: $error');

      rethrow;
    }
  }

  Future<List<UserData>?> searchUsers(String token, String? username,
      String? email, String? firstName, String? lastName, String? role) async {
    try {
      var urlString = '$baseUrl/search?';
      var extras = false;
      if (username != null ||
          email != null ||
          firstName != null ||
          lastName != null ||
          role != null) {
        extras = true;
      }

      if (username != null) urlString = '${urlString}username=$username&';
      if (email != null) urlString = '${urlString}email=$email&';
      if (firstName != null) urlString = '${urlString}firstName=$firstName&';
      if (lastName != null) urlString = '${urlString}lastName=$lastName&';
      if (role != null) urlString = '${urlString}rol=$role&';

      if (extras == true) {
        urlString = urlString.substring(0, urlString.length - 1);
      }

      var url = Uri.parse(urlString);

      final response = await http.get(url, headers: _getHeadersAlt(token));

      if (response.statusCode == 200) {
        return parseUserListResponse(response);
      } else {
        printOnDebug('No se pudieron traer datos');
        return null;
      }
    } catch (error) {
      printOnDebug('Error in searchUsers: $error');
      rethrow;
    }
  }

  parseUserListResponse(http.Response response) {
    final data = json.decode(response.body);

    return data.map<UserData>((userData) {
      return UserData(
          id: userData['id'],
          email: userData['email'] ?? 'null',
          firstName: userData['firstName'] ?? 'null',
          lastName: userData['lastName'] ?? 'null',
          username: userData['username'],
          rol: userData['rol']);
    }).toList();
  }

  parseUsernamesListResponse(http.Response response) {
    final data = json.decode(response.body);

    var list = data.map<String>((userData) {
      return userData['username'].toString();
    }).toList();

    return list;
  }
}
