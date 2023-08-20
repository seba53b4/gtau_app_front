import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SelectedItemsProvider with ChangeNotifier {

  bool _multipleItemsSelected = false;
  bool get multipleItemsSelected => _multipleItemsSelected;

  Set<PolylineId> _selectedSections = {};
  Set<PolylineId> get selectedPolylines => _selectedSections;

  Set<MarkerId> _selectedRegistros = {};
  Set<MarkerId> get selectedRegistros => _selectedRegistros;

  Set<MarkerId> _selectedCaptaciones = {};
  Set<MarkerId> get selectedCaptaciones => _selectedCaptaciones;

  void activateMultipleSelection(){
    _multipleItemsSelected = true;
  }

  void toggleSectionSelected(PolylineId polylineId) {
    if (_selectedSections.contains(polylineId)) {
      _selectedSections.remove(polylineId);
    } else {
      if (_selectedSections.isEmpty || _multipleItemsSelected) {
        _selectedSections.add(polylineId);
      }
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
      if (_selectedRegistros.isEmpty || _multipleItemsSelected) {
        _selectedRegistros.add(markerId);
      }
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
      if (_selectedCaptaciones.isEmpty || _multipleItemsSelected) {
        _selectedCaptaciones.add(markerId);
      }
    }
    notifyListeners();
  }

  bool isCaptacionSelected(MarkerId markerId) {
    return _selectedCaptaciones.contains(markerId);
  }

  void clearAllSelections(){
    _selectedCaptaciones.clear();
    _selectedSections.clear();
    _selectedRegistros.clear();
  }

  void reset(){
    clearAllSelections();
    _multipleItemsSelected = false;
  }

}
