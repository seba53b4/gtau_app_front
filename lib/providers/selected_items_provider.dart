import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SelectedItemsProvider with ChangeNotifier {
  bool _letMultipleItemsSelected = false;

  bool get letMultipleItemsSelected => _letMultipleItemsSelected;

  Set<PolylineId> _selectedSections = {};

  Set<PolylineId> get selectedPolylines => _selectedSections;

  Set<CircleId> _selectedRegisters = {};

  Set<CircleId> get selectedRegisters => _selectedRegisters;

  Set<CircleId> _selectedCatchments = {};

  Set<CircleId> get selectedCatchments => _selectedCatchments;

  void activateMultipleSelection() {
    _letMultipleItemsSelected = true;
  }

  void toggleSectionSelected(PolylineId polylineId) {
    if (_selectedSections.contains(polylineId)) {
      _selectedSections.remove(polylineId);
    } else {
      if (_selectedSections.isEmpty || _letMultipleItemsSelected) {
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

  void setCatchments(Set<CircleId>? catchments) {
    if (catchments != null) {
      _selectedCatchments = catchments;
      notifyListeners();
    }
  }

  void setRegisters(Set<CircleId>? registers) {
    if (registers != null) {
      _selectedRegisters = registers;
      notifyListeners();
    }
  }

  bool isSectionSelected(PolylineId polylineId) {
    return _selectedSections.contains(polylineId);
  }

  void toggleRegistroSelected(CircleId circleId) {
    if (_selectedRegisters.contains(circleId)) {
      _selectedRegisters.remove(circleId);
    } else {
      if (_selectedRegisters.isEmpty || _letMultipleItemsSelected) {
        _selectedRegisters.add(circleId);
      }
    }
    notifyListeners();
  }

  bool isRegistroSelected(CircleId circleId) {
    return _selectedRegisters.contains(circleId);
  }

  bool isSomeRegisterSelected() {
    return _selectedRegisters.isNotEmpty;
  }

  bool isSomeCatchmentSelected() {
    return _selectedCatchments.isNotEmpty;
  }

  bool isSomeSectionSelected() {
    return _selectedSections.isNotEmpty;
  }

  void toggleCatchmentSelected(CircleId circleId) {
    if (_selectedCatchments.contains(circleId)) {
      _selectedCatchments.remove(circleId);
    } else {
      if (_selectedCatchments.isEmpty || _letMultipleItemsSelected) {
        _selectedCatchments.add(circleId);
      }
    }
    notifyListeners();
  }

  bool isCatchmentSelected(CircleId circleId) {
    return _selectedCatchments.contains(circleId);
  }

  bool isSomeElementSelected() {
    return _selectedSections.isNotEmpty ||
        _selectedCatchments.isNotEmpty ||
        _selectedRegisters.isNotEmpty;
  }

  void clearAllSelections() {
    _selectedCatchments.clear();
    _selectedSections.clear();
    _selectedRegisters.clear();
  }

  void reset() {
    clearAllSelections();
    _letMultipleItemsSelected = false;
  }
}
