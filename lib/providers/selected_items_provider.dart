import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SelectedItemsProvider with ChangeNotifier {
  bool _multipleItemsSelected = false;
  bool get multipleItemsSelected => _multipleItemsSelected;

  Set<PolylineId> _selectedSections = {};
  Set<PolylineId> get selectedPolylines => _selectedSections;

  Set<MarkerId> _selectedRegistros = {};
  Set<MarkerId> get selectedRegistros => _selectedRegistros;

  Set<CircleId> _selectedCaptaciones = {};
  Set<CircleId> get selectedCaptaciones => _selectedCaptaciones;

  void activateMultipleSelection() {
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

  void setSections(Set<PolylineId>? sections) {
    if (sections != null) {
      _selectedSections = sections;
      notifyListeners();
    }
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

  void toggleCaptacionSelected(CircleId circleId) {
    if (_selectedCaptaciones.contains(circleId)) {
      _selectedCaptaciones.remove(circleId);
    } else {
      if (_selectedCaptaciones.isEmpty || _multipleItemsSelected) {
        _selectedCaptaciones.add(circleId);
      }
    }
    notifyListeners();
  }

  bool isCaptacionSelected(CircleId circleId) {
    return _selectedCaptaciones.contains(circleId);
  }

  void clearAllSelections() {
    _selectedCaptaciones.clear();
    _selectedSections.clear();
    _selectedRegistros.clear();
    notifyListeners();
  }

  void reset() {
    clearAllSelections();
    _multipleItemsSelected = false;
  }
}
