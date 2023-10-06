import 'package:flutter/foundation.dart';

import '../models/section_data.dart';
import '../services/section_service.dart';

class SectionViewModel extends ChangeNotifier {
  final SectionService _sectionService = SectionService();

  List<Section> _sections = [];

  List<Section> get sections => _sections;

  late Section? _sectionForDetail = null;

  Section? get sectionForDetail => _sectionForDetail;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<List<Section>?> fetchSectionsByRadius(
      String token, double longitude, double latitude, int radiusMtr) async {
    try {
      _isLoading = true;
      notifyListeners();
      final responseListSection = await _sectionService.fetchSectionsByRadius(
          token, longitude, latitude, radiusMtr);
      if (responseListSection != null) {
        _sections = responseListSection;
      }
      _isLoading = false;
      notifyListeners();

      return responseListSection;
    } catch (error) {
      print(error);
      _isLoading = false;
      throw Exception('Error al obtener los datos: $error');
    }
  }

  Future<Section?> fetchSectionById(String token, int sectionId) async {
    try {
      _isLoading = true;
      _sectionForDetail = null;
      notifyListeners();
      final responseSection =
          await _sectionService.fetchSectionById(token, sectionId);
      if (responseSection != null) {
        _sectionForDetail = responseSection;
      }
      _isLoading = false;
      notifyListeners();

      return responseSection;
    } catch (error) {
      _isLoading = false;
      if (kDebugMode) {
        print('Error al obtener tramos: $error');
      }
      rethrow;
    }
  }

  clearAll() {
    _sections = [];
    _isLoading = false;
    _sectionForDetail = null;
    notifyListeners();
  }
}
