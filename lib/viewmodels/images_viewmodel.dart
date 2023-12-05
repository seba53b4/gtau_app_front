import 'package:flutter/foundation.dart';
import 'package:gtau_app_front/services/task_service.dart';

import '../widgets/image_gallery_modal.dart';

class ImagesViewModel extends ChangeNotifier {
  final TaskService _taskService = TaskService();

  List<Photo> _photos = [];

  List<Photo> get photos => _photos;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  bool _error = false;

  bool get error => _error;

  List<Photo> parsePhotos(List<String> urls) {
    return urls.map((url) => Photo(url: url)).toList();
  }

  Future<List<String>> fetchTaskImages(token, int idTask) async {
    try {
      _isLoading = true;
      _error = false;
      notifyListeners();
      final List<String> responseTask =
          await _taskService.fetchTaskImages(token, idTask);
      
      final leng = responseTask.length;
      print('largo response $leng');

      if (responseTask.isNotEmpty) {
        _photos = parsePhotos(responseTask);
      } else {
        _photos = [];
        if (kDebugMode) {
          print('No se pudieron traer datos');
        }
      }
      
      // Se usa Future.microtask para retrasar la llamada a notifyListeners()
      Future.microtask(() {
        _isLoading = false;
        notifyListeners();
      });
      return responseTask;
    } catch (error) {
      _error = true;
      if (kDebugMode) {
        print(error);
      }
      throw Exception('Error al obtener los datos');
    }
  }

  Future<List<String>> fetchTaskImagesWithDelay(token, int idTask, int delaysec) async {
    try {
      _isLoading = true;
      _error = false;
      notifyListeners();
      await new Future.delayed(Duration(seconds: delaysec));
      final List<String> responseTask =
          await _taskService.fetchTaskImages(token, idTask);
      
      final leng = responseTask.length;
      print('largo response $leng');

      if (responseTask.isNotEmpty) {
        _photos = parsePhotos(responseTask);
      } else {
        _photos = [];
        if (kDebugMode) {
          print('No se pudieron traer datos');
        }
      }
      
      // Se usa Future.microtask para retrasar la llamada a notifyListeners()
      Future.microtask(() {
        _isLoading = false;
        notifyListeners();
      });
      return responseTask;
    } catch (error) {
      _error = true;
      if (kDebugMode) {
        print(error);
      }
      throw Exception('Error al obtener los datos');
    }
  }

  uploadImage(String token, int id, String path) {
    _isLoading = true;
    notifyListeners();
    if (kIsWeb) {
      _taskService.putBase64Images(token, id, path);
    } else {
      _taskService.putMultipartImages(token, id, path);
    }
    _isLoading = false;
    notifyListeners();
  }

  uploadImages(String token, int id, List<String> listpath) async{
    _isLoading = true;
    notifyListeners();
    listpath!.forEach((path) async {
      if (kIsWeb) {
        _taskService.putBase64Images(token, id, path);
      } else {
        _taskService.putMultipartImages(token, id, path);
      }
    });
    await new Future.delayed(const Duration(seconds: 2));
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> deleteImage(String token, int id, String path) async {
    try {
      _isLoading = true;
      _error = false;

      final bool response = await _taskService.deleteTaskImage(token, id, path);

      if (!response) {
        _error = true;
        if (kDebugMode) {
          print('Error al eliminar la imagen');
        }
      }

      // Se usa Future.microtask para retrasar la llamada a notifyListeners()
      Future.microtask(() {
        _isLoading = false;
        notifyListeners();
      });

      return response;
    } catch (error) {
      _error = true;
      if (kDebugMode) {
        print(error);
      }
      throw Exception('Error al eliminar imagen');
    }
  }
}
