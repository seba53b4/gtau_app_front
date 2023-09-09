import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SelectedItemsProvider with ChangeNotifier {
  bool _multipleItemsSelected = false;

  bool get multipleItemsSelected => _multipleItemsSelected;

  Set<PolylineId> _selectedSections = {};

  Set<PolylineId> get selectedPolylines => _selectedSections;

  Set<MarkerId> _selectedRegistros = {};

  Set<MarkerId> get selectedRegistros => _selectedRegistros;

  Set<CircleId> _selectedCatchment = {};

  Set<CircleId> get selectedCatchment => _selectedCatchment;

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

  void toggleCatchmentSelected(CircleId circleId) {
    if (_selectedCatchment.contains(circleId)) {
      _selectedCatchment.remove(circleId);
    } else {
      if (_selectedCatchment.isEmpty || _multipleItemsSelected) {
        _selectedCatchment.add(circleId);
      }
    }
    notifyListeners();
  }

  bool isCatchmentSelected(CircleId circleId) {
    return _selectedCatchment.contains(circleId);
  }

  void clearAllSelections() {
    _selectedCatchment.clear();
    _selectedSections.clear();
    _selectedRegistros.clear();
    notifyListeners();
  }

  void reset() {
    clearAllSelections();
    _multipleItemsSelected = false;
  }
}
