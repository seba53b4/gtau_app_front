import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gtau_app_front/models/register_data.dart';
import 'package:gtau_app_front/services/register_service.dart';

class RegisterViewModel extends ChangeNotifier {
  final RegisterService _registerService = RegisterService();

  List<Register> _registers = [];

  List<Register> get catchments => _registers;

  Future<List<Register>?> fetchRegistersByRadius(
      String token, double longitude, double latitude, int radiusMtr) async {
    try {
      final responseListSection = await _registerService.fetchRegistersByRadius(
          token, longitude, latitude, radiusMtr);
      if (responseListSection != null) {
        _registers = responseListSection;
      }
      notifyListeners();
      return responseListSection;
    } catch (error) {
      print(error);
      throw Exception('Error al obtener los datos: $error');
    }
  }
}
