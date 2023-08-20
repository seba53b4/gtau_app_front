import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SelectedItemsProvider with ChangeNotifier {
  Set<PolylineId> _selectedSections = {};
  Set<PolylineId> get selectedPolylines => _selectedSections;

  Set<MarkerId> _selectedRegistros = {};
  Set<MarkerId> get selectedRegistros => _selectedRegistros;

  Set<MarkerId> _selectedCaptaciones = {};
  Set<MarkerId> get selectedCaptaciones => _selectedCaptaciones;


  void toggleSectionSelected(PolylineId polylineId) {
    if (_selectedSections.contains(polylineId)) {
      _selectedSections.remove(polylineId);
    } else {
      _selectedSections.add(polylineId);
    }
    notifyListeners();
  }

  bool isSectionSelected(PolylineId polylineId) {
    return _selectedSections.contains(polylineId);
  }

  void toggleRegistroSelected(MarkerId markerId) {
    if (_selectedRegistros.contains(markerId)) {
      _selectedRegistros.remove(markerId);
    } else {
      _selectedRegistros.add(markerId);
    }
    notifyListeners();
  }

  bool isRegistroSelected(MarkerId markerId) {
    return _selectedRegistros.contains(markerId);
  }

  void toggleCaptacionSelected(MarkerId markerId) {
    if (_selectedCaptaciones.contains(markerId)) {
      _selectedCaptaciones.remove(markerId);
    } else {
      _selectedCaptaciones.add(markerId);
    }
    notifyListeners();
  }

  bool isCaptacionSelected(MarkerId markerId) {
    return _selectedCaptaciones.contains(markerId);
  }

  void clearAll(){
    _selectedCaptaciones.clear();
    _selectedSections.clear();
    _selectedRegistros.clear();
  }

}
