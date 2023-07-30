import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class TaskService {
  final String baseUrl;

  TaskService({String? baseUrl}) : baseUrl = baseUrl ?? dotenv.get('API_TASKS_URL', fallback: 'NOT_FOUND');

  Future<http.Response> getTasks(String token, String user, int page, int size, String status) async {
    String userByType = dotenv.get('BY_USER_N_TYPE_URL', fallback: 'NOT_FOUND');
    final url = Uri.parse('$baseUrl/$userByType?page=$page&size=$size&user=$user&status=$status');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return response;
  }

  Future<http.Response> deleteTask(String token, int id) async {

    final url = Uri.parse('$baseUrl/$id');
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "BEARER $token"
      },
    );

    return response;

  }


}
