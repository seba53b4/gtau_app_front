
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gtau_app_front/models/task.dart';
import 'package:gtau_app_front/services/task_service.dart';
import 'package:provider/provider.dart';
import '../models/section_data.dart';
import '../providers/user_provider.dart';
import '../services/section_service.dart';

class SectionViewModel extends ChangeNotifier {
  final SectionService _sectionService = SectionService();

  List<Section> _sections = [];
  List<Section> get sections => _sections;

  Future<List<Section>?> fetchSectionsByRadius(String token, double longitude, double latitude, int radiusMtr) async {
    try {
      final responseListSection = await _sectionService.fetchSectionsByRadius(token, longitude, latitude, radiusMtr);
      if (responseListSection != null) {
        _sections = responseListSection;
      }
      notifyListeners();
      return responseListSection;
    } catch (error) {
      print(error);
      throw Exception('Error al obtener los datos: $error');
    }
  }
}






