import 'package:flutter/foundation.dart';
import 'package:gtau_app_front/services/task_service.dart';

import '../utils/common_utils.dart';

class InformeViewModel extends ChangeNotifier {
  final TaskService _taskService = TaskService();

  List<Map<String, dynamic>> _informes = [];

  List<Map<String, dynamic>> get informes => _informes;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  bool _error = false;

  bool get error => _error;

  List<Map<String, dynamic>> parseInformes(List<String> urls) {
    return urls.map((url) => {"url": url}).toList();
  }

  void reset() {
    _informes = [];
  }

  Future<List<Map<String, dynamic>>> fetchTaskInformes(
      token, int idTask) async {
    try {
      _isLoading = true;
      _error = false;
      final List<String> responseTask =
          await _taskService.fetchTaskInformes(token, idTask);

      if (responseTask.isNotEmpty) {
        _informes = parseInformes(responseTask);
      } else {
        _informes = [];
        printOnDebug('No se pudieron traer datos');
      }

      // Se usa Future.microtask para retrasar la llamada a notifyListeners()
      Future.microtask(() {
        _isLoading = false;
        notifyListeners();
      });
      return _informes;
    } catch (error) {
      _error = true;
      printOnDebug(error);
      throw Exception('Error al obtener los datos');
    }
  }

  Future<String> uploadInforme(
      String token, int id, Map<String, dynamic> informe) async {
    _isLoading = true;
    String result = '';
    notifyListeners();
    // if (kIsWeb) {
    result = await _taskService.putBase64Informes(token, id, informe);
    // } else {
    //   result = await _taskService.putMultipartInformes(token, id, informe);
    // }
    _isLoading = false;
    notifyListeners();
    return result;
  }

  Future<String> uploadInformes(
      String token, int id, List<Map<String, dynamic>> listinformes) async {
    _isLoading = true;
    String result = '';
    notifyListeners();
    for (var informe in listinformes!) {
      // if (kIsWeb) {
      result = await _taskService.putBase64Informes(token, id, informe);
      // if (finalList == null) {
      //   result = result && false;
      // } else {
      //   result = result && true;
      // }
      // } else {
      //   final resultprocess =
      //   await _taskService.putMultipartInformes(token, id, informe);
      //   result = result && resultprocess;
      // }
    }
    /*await new Future.delayed(const Duration(seconds: 2));*/
    _isLoading = false;
    notifyListeners();
    return result;
  }

  Future<bool> deleteInforme(String token, int id, String informe) async {
    try {
      _isLoading = true;
      _error = false;
      notifyListeners();

      final bool response =
          await _taskService.deleteTaskInforme(token, id, informe);

      if (!response) {
        _error = true;
        printOnDebug('Error al eliminar el informe');
      }

      // Se usa Future.microtask para retrasar la llamada a notifyListeners()
      Future.microtask(() {
        _isLoading = false;
        notifyListeners();
      });

      return response;
    } catch (error) {
      _error = true;
      printOnDebug(error);
      throw Exception('Error al eliminar informes');
    }
  }
}
