import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class TaskService {
  final String baseUrl;

  TaskService({String? baseUrl}) : baseUrl = baseUrl ?? dotenv.get('API_TASKS_URL', fallback: 'NOT_FOUND');

  Map<String, String> _getHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> getTasks(String token, String user, int page, int size, String status) async {
    try {
      String userByType = dotenv.get('BY_USER_N_TYPE_URL', fallback: 'NOT_FOUND');
      final url = Uri.parse('$baseUrl/$userByType?page=$page&size=$size&user=$user&status=$status');
      final response = await http.get(
        url,
        headers: _getHeaders(token)
      );
      return response;
    } catch (error) {
      if (kDebugMode) {
        print('Error in getTasks: $error');
      }
      rethrow;
    }
  }

  Future<http.Response> deleteTask(String token, int id) async {
    try {
      final url = Uri.parse('$baseUrl/$id');
      final response = await http.delete(
        url,
        headers: _getHeaders(token)
      );
      return response;
    } catch (error) {
      if (kDebugMode) {
        print('Error in deleteTask: $error');
      }
      rethrow;
    }

  }

  Future<http.Response> fetchTask(token, int idTask) async {
    try {
      final url = Uri.parse('$baseUrl/$idTask');
      final response = await http.get(
          url,
          headers: _getHeaders(token)
      );
      return response;
    } catch (error){
      if (kDebugMode) {
        print('Error in fetchTask: $error');
      }
      rethrow;
    }
  }

  Future<http.Response> updateTask(String token, int idTask, Map<String, dynamic> body) async {
    try {
      final url = Uri.parse('$baseUrl/$idTask');
      final String jsonBody = jsonEncode(body);
      final response = await http.put(
          url,
          headers: _getHeaders(token),
          body: jsonBody
      );
      return response;
    } catch (error){
      if (kDebugMode) {
        print('Error in updateTask: $error');
      }
      rethrow;
    }
  }


}
