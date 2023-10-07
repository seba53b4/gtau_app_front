import 'package:flutter/foundation.dart';

import '../models/catchment_data.dart';
import '../services/catchment_service.dart';

class CatchmentViewModel extends ChangeNotifier {
  final CatchmentService _catchmentService = CatchmentService();

  List<Catchment> _catchments = [];

  List<Catchment> get catchments => _catchments;

  late Catchment? _catchmentForDetail = null;

  Catchment? get catchmentForDetail => _catchmentForDetail;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<List<Catchment>?> fetchCatchmentsByRadius(
      String token, double longitude, double latitude, int radiusMtr) async {
    try {
      _isLoading = true;
      notifyListeners();
      final responseListSection = await _catchmentService
          .fetchCatchmentsByRadius(token, longitude, latitude, radiusMtr);
      if (responseListSection != null) {
        _catchments = responseListSection;
      }
      _isLoading = false;
      notifyListeners();
      return responseListSection;
    } catch (error) {
      print(error);
      throw Exception('Error al obtener los datos: $error');
    }
  }

  Future<Catchment?> fetchCatchmentById(String token, int catchmentId) async {
    try {
      _isLoading = true;
      _catchmentForDetail = null;
      notifyListeners();
      final responseCatchment =
          await _catchmentService.fetchCatchmentById(token, catchmentId);
      if (responseCatchment != null) {
        _catchmentForDetail = responseCatchment;
      }
      _isLoading = false;
      notifyListeners();
      return responseCatchment;
    } catch (error) {
      _isLoading = false;
      if (kDebugMode) {
        print('Error al obtener captaciones: $error');
      }
      rethrow;
    }
  }
}
