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

  Future<List<Register>?> fetchRegistersByRadius(
      String token, double longitude, double latitude, int radiusMtr) async {
    try {
      _isLoading = true;
      notifyListeners();
      final responseListSection = await _registerService.fetchRegistersByRadius(
          token, longitude, latitude, radiusMtr);
      if (responseListSection != null) {
        _registers = responseListSection;
        _isLoading = false;
      }
      notifyListeners();
      return responseListSection;
    } catch (error) {
      print(error);
      throw Exception('Error al obtener los datos: $error');
    }
  }

  Future<Register?> fetchRegisterById(String token, int sectionId) async {
    try {
      _isLoading = true;
      _registerForDetail = null;
      notifyListeners();
      final responseRegister =
          await _registerService.fetchRegisterById(token, sectionId);
      if (responseRegister != null) {
        _registerForDetail = responseRegister;
        _isLoading = false;
      }
      notifyListeners();
      return responseRegister;
    } catch (error) {
      _isLoading = false;
      if (kDebugMode) {
        print('Error al obtener registros: $error');
      }
      rethrow;
    }
  }
}
