import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/catchment_data.dart';
import '../services/catchment_service.dart';

class CatchmentViewModel extends ChangeNotifier {
  final CatchmentService _catchmentService = CatchmentService();

  List<Catchment> _catchments = [];

  List<Catchment> get catchments => _catchments;

  Future<List<Catchment>?> fetchCatchmentsByRadius(
      String token, double longitude, double latitude, int radiusMtr) async {
    try {
      final responseListSection = await _catchmentService
          .fetchCatchmentsByRadius(token, longitude, latitude, radiusMtr);
      if (responseListSection != null) {
        _catchments = responseListSection;
      }
      notifyListeners();
      return responseListSection;
    } catch (error) {
      print(error);
      throw Exception('Error al obtener los datos: $error');
    }
  }
}
