import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;

import '../models/enums/element_type.dart';

class ImagesService {
  final String baseUrlTask;
  final String baseUrlScheduled;

  ImagesService({String? baseUrlTask, String? baseUrlScheduled})
      : baseUrlTask =
            baseUrlTask ?? dotenv.get('API_TASKS_URL', fallback: 'NOT_FOUND'),
        baseUrlScheduled = baseUrlScheduled ??
            dotenv.get('API_SCHEDULED_TASKS_URL', fallback: 'NOT_FOUND');

  Map<String, String> _getHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<String>> fetchTaskImages(token, int idTask) async {
    try {
      final url = Uri.parse('$baseUrlTask/$idTask/images');
      final response = await http.get(url, headers: _getHeaders(token));
      if (response.statusCode == 200) {
        List<dynamic> decode = json.decode(response.body) as List<dynamic>;
        List<String> newList =
            await decode.map((e) => e["image"].toString()).toList();
        await new Future.delayed(
            Duration(seconds: 1)); /*Simulamos el delay de una lenta conexion*/
        return await newList;
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

  Future<List<String>> fetchImagesScheduledElement(
      token, int scheduledId, int elementId, ElementType elementType) async {
    try {
      final url = Uri.parse(
          '$baseUrlScheduled/$scheduledId/${elementType.pluralName}/$elementId/images');
      final response = await http.get(url, headers: _getHeaders(token));
      if (response.statusCode == 200) {
        List<dynamic> decode = json.decode(response.body) as List<dynamic>;
        List<String> newList =
            await decode.map((e) => e["image"].toString()).toList();
        // await Future.delayed(
        //     Duration(seconds: 1)); /*Simulamos el delay de una lenta conexion*/
        return await newList;
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

  Future<List<String>> fetchTaskImagesWithDelay(
      token, int idTask, int delaysec) async {
    try {
      final url = Uri.parse('$baseUrlTask/$idTask/images');
      final response = await http.get(url, headers: _getHeaders(token));
      if (response.statusCode == 200) {
        List<dynamic> decode = json.decode(response.body) as List<dynamic>;
        List<String> newList =
            await decode.map((e) => e["image"].toString()).toList();
        await new Future.delayed(Duration(
            seconds: delaysec)); /*Simulamos el delay de una lenta conexion*/
        return await newList;
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
      final url = Uri.parse('$baseUrlTask/$id/image/v2');
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

  Future<List<String>?> putBase64ImagesScheduled(String token, int scheduledId,
      int elementId, String path, ElementType elementType) async {
    try {
      Uri uri = Uri.parse(path);
      String basename = p.basename(uri.path);

      Map<String, String> imageEncode = await imageToBase64(path);
      var extension = imageEncode['ext'];
      var content = imageEncode['content'];
      var base64 = imageEncode['base64'];
      final Map<String, dynamic> body = {
        "image": "$content,$base64",
        "name": "$basename.$extension",
        "type": elementType.pluralName,
        "entityId": elementId
      };

      final String jsonBody = jsonEncode(body);
      final url = Uri.parse('$baseUrlScheduled/$scheduledId/image/v2');
      final response =
          await http.post(url, headers: _getHeaders(token), body: jsonBody);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse.entries.map<String>((entry) {
          return "${entry.key}: ${entry.value}"; //Agrego esto por aca solo para que no salte error
        }).toList();
      } else {
        return null;
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error al guardar putBase64ImagesScheduled: $error');
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
      final url = Uri.parse('$baseUrlTask/$id/image');
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

  Future<bool> putMultipartImagesScheduled(String token, int scheduledId,
      int elementId, String path, ElementType elementType) async {
    try {
      final params = {
        'entity_type': '${elementType.pluralName}',
        'entity_id': '$elementId'
      };
      final query = Uri(queryParameters: params).query;
      final url = Uri.parse('$baseUrlScheduled/$scheduledId/image?$query');
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

  Future<bool> deleteTaskImage(String token, int id, String path) async {
    try {
      var fileName = path.split("/").last;
      final Map<String, dynamic> body = {"name": fileName};

      final String jsonBody = jsonEncode(body);
      final url = Uri.parse('$baseUrlTask/$id/image');
      final response =
          await http.delete(url, headers: _getHeaders(token), body: jsonBody);

      if (response.statusCode == 200) {
        final bool jsonResponse = json.decode(response.body);

        return jsonResponse;
      } else {
        return false;
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error al guardar imagenes: $error');
      }
      rethrow;
    }
  }

  Future<bool> deleteTaskImageScheduled(
      String token, int scheduledId, String path) async {
    try {
      var fileName = path.split("/").last;
      final Map<String, dynamic> body = {"name": fileName};

      final String jsonBody = jsonEncode(body);
      final url = Uri.parse('$baseUrlScheduled/$scheduledId/image');
      final response =
          await http.delete(url, headers: _getHeaders(token), body: jsonBody);

      if (response.statusCode == 200) {
        final bool jsonResponse = json.decode(response.body);

        return jsonResponse;
      } else {
        return false;
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error al guardar imagenes: $error');
      }
      rethrow;
    }
  }
}
