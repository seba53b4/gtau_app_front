import 'package:flutter/foundation.dart';

import '../models/lot_data.dart';
import '../services/lot_service.dart';

class LotViewModel extends ChangeNotifier {
  final LotService _LotService = LotService();

  List<Lot> _Lots = [];

  List<Lot> get Lots => _Lots;

  late Lot? _lotForDetail = null;

  Lot? get lotForDetail => _lotForDetail;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  bool _error = false;

  bool get error => _error;

  void reset() {
    _error = false;
    _isLoading = false;
    _lotForDetail = null;
    _Lots.clear();
  }

  Future<List<Lot>?> fetchLotsByRadius(String token, double longitude,
      double latitude, int radiusMtr) async {
    try {
      _isLoading = true;
      notifyListeners();
      final responseListSection = await _LotService.fetchLotsByRadius(
          token, longitude, latitude, radiusMtr);
      if (responseListSection != null) {
        _Lots = responseListSection;
      }
      _isLoading = false;
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

  Future<Lot?> fetchLotById(String token, int LotId) async {
    try {
      _isLoading = true;
      _lotForDetail = null;
      notifyListeners();
      final responseLot = await _LotService.fetchLotById(token, LotId);
      if (responseLot != null) {
        _lotForDetail = responseLot;
      }
      _isLoading = false;

      return responseLot;
    } catch (error) {
      _error = true;
      if (kDebugMode) {
        print('Error al obtener captaciones: $error');
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
