import 'package:flutter/foundation.dart';

import '../models/enums/element_type.dart';
import '../services/images_service.dart';
import '../widgets/photo.dart';

class ImagesViewModel extends ChangeNotifier {
  final ImagesService _imagesService = ImagesService();

  List<Photo> _photos = [];

  List<Photo> get photos => _photos;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  bool _error = false;

  bool get error => _error;

  List<Photo> parsePhotos(List<String> urls) {
    return urls.map((url) => Photo(url: url)).toList();
  }

  void reset() {
    _photos = [];
  }

  Future<List<String>> fetchTaskImages(token, int idTask) async {
    try {
      _isLoading = true;
      _error = false;
      final List<String> responseTask =
          await _imagesService.fetchTaskImages(token, idTask);

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

  Future<List<String>> fetchImagesScheduledElement(
      token, int scheduledId, int elementId, ElementType elementType) async {
    try {
      _isLoading = true;
      _error = false;
      final List<String> response =
          await _imagesService.fetchImagesScheduledElement(
              token, scheduledId, elementId, elementType);

      if (response.isNotEmpty) {
        _photos = parsePhotos(response);
      } else {
        _photos = [];

        if (kDebugMode) {
          print('Imagenes vacío');
        }
      }

      // Se usa Future.microtask para retrasar la llamada a notifyListeners()
      // await Future.microtask(() {
      //   _isLoading = false;
      //   notifyListeners();
      // });
      return response;
    } catch (error) {
      _error = true;
      if (kDebugMode) {
        print(error);
      }
      throw Exception('Error al obtener los datos');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadImage(String token, int id, String path) async {
    _isLoading = true;
    bool result = true;
    notifyListeners();
    if (kIsWeb) {
      await _imagesService.putBase64Images(token, id, path);
    } else {
      result = await _imagesService.putMultipartImages(token, id, path);
    }
    _isLoading = false;
    notifyListeners();
    return result;
  }

  Future<bool> scheduledUploadImage(String token, int scheduledId,
      int elementId, String path, ElementType elementType) async {
    _isLoading = true;
    bool result = true;
    notifyListeners();
    if (kIsWeb) {
      await _imagesService.putBase64ImagesScheduled(
          token, scheduledId, elementId, path, elementType);
    } else {
      result = await _imagesService.putMultipartImagesScheduled(
          token, scheduledId, elementId, path, elementType);
    }
    _isLoading = false;
    notifyListeners();
    return result;
  }

  Future<bool> uploadImages(String token, int id, List<String> listpath) async {
    _isLoading = true;
    bool result = true;
    notifyListeners();
    for (var path in listpath!) {
      if (kIsWeb) {
        final finalList = await _imagesService.putBase64Images(token, id, path);
        if (finalList == null) {
          result = result && false;
        } else {
          result = result && true;
        }
      } else {
        final resultprocess =
            await _imagesService.putMultipartImages(token, id, path);
        result = result && resultprocess;
      }
    }
    /*await new Future.delayed(const Duration(seconds: 2));*/
    _isLoading = false;
    notifyListeners();
    return result;
  }

  Future<bool> scheduledUploadImages(
    String token,
    int scheduledId,
    int elementId,
    List<String> listpath,
    ElementType elementType,
  ) async {
    _isLoading = true;
    bool result = true;
    notifyListeners();
    for (var path in listpath) {
      if (kIsWeb) {
        final finalList = await _imagesService.putBase64ImagesScheduled(
            token, scheduledId, elementId, path, elementType);
        if (finalList == null) {
          result = result && false;
        } else {
          result = result && true;
        }
      } else {
        final resultprocess = await _imagesService.putMultipartImagesScheduled(
            token, scheduledId, elementId, path, elementType);
        result = result && resultprocess;
      }
    }
    _isLoading = false;
    notifyListeners();
    return result;
  }

  Future<bool> deleteImage(String token, int id, String path) async {
    try {
      _isLoading = true;
      _error = false;
      notifyListeners();

      final bool response =
          await _imagesService.deleteTaskImage(token, id, path);

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

  Future<bool> deleteImageScheduled(
      String token, int scheduledId, String path) async {
    try {
      _isLoading = true;
      _error = false;
      notifyListeners();

      final bool response = await _imagesService.deleteTaskImageScheduled(
          token, scheduledId, path);

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
