import 'package:flutter/foundation.dart';
import 'package:gtau_app_front/models/register_data.dart';
import 'package:gtau_app_front/services/register_service.dart';

class RegisterViewModel extends ChangeNotifier {
  final RegisterService _registerService = RegisterService();

  List<Register> _registers = [];

  List<Register> get registers => _registers;

  late Register? _registerForDetail = null;

  Register? get registerForDetail => _registerForDetail;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  bool _error = false;

  bool get error => _error;

  void reset() {
    _error = false;
    _isLoading = false;
    _registerForDetail = null;
    _registers.clear();
  }

  void resetError() {
    _error = false;
  }

  Future<List<Register>?> fetchRegistersByRadius(
      String token, double longitude, double latitude, int radiusMtr) async {
    try {
      _isLoading = true;
      notifyListeners();
      await Future.delayed(Duration(milliseconds: 1500));
      throw Error();
      final responseListSection = await _registerService.fetchRegistersByRadius(
          token, longitude, latitude, radiusMtr);
      if (responseListSection != null) {
        _registers = responseListSection;
      }
      return responseListSection;
    } catch (error) {
      _error = true;
      print(error);
      throw Exception('Error al obtener los datos: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Register?> fetchRegisterById(String token, int registerId) async {
    try {
      _isLoading = true;
      _registerForDetail = null;
      notifyListeners();
      final responseRegister =
          await _registerService.fetchRegisterById(token, registerId);
      if (responseRegister != null) {
        _registerForDetail = responseRegister;
      }
      return responseRegister;
    } catch (error) {
      _error = true;
      if (kDebugMode) {
        print('Error al obtener registros: $error');
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
