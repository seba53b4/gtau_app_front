import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/enums/element_type.dart';

class SelectedItemsProvider with ChangeNotifier {
  bool _letMultipleItemsSelected = false;

  Set<PolylineId> _initialSelectedSections = {};
  Set<PolylineId> _currentSelectedSections = {};

  Set<CircleId> _initialSelectedRegisters = {};
  Set<CircleId> _currentSelectedRegisters = {};

  Set<CircleId> _initialSelectedCatchments = {};
  Set<CircleId> _currentSelectedCatchments = {};

  Set<PolylineId> _initialSelectedLots = {};
  Set<PolylineId> _currentSelectedLots = {};

  LatLng _initialInspectionPosition = const LatLng(0, 0);
  LatLng _currentInspectionPosition = const LatLng(0, 0);

  bool get letMultipleItemsSelected => _letMultipleItemsSelected;

  Set<PolylineId> get selectedPolylines => _currentSelectedSections;

  Set<CircleId> get selectedRegisters => _currentSelectedRegisters;

  Set<CircleId> get selectedCatchments => _currentSelectedCatchments;

  Set<PolylineId> get selectedLots => _currentSelectedLots;

  LatLng get inspectionPosition => _currentInspectionPosition;


  void setInspectionPosition(LatLng position) {
    _currentInspectionPosition = position;
    notifyListeners();
  }

  void activateMultipleSelection() {
    _letMultipleItemsSelected = true;
  }

  void togglePolylineSelected(PolylineId polylineId, ElementType type) {
    var list = getPolylineList(type);
    if (list.contains(polylineId)) {
      list.remove(polylineId);
    } else {
      if (list.isEmpty || _letMultipleItemsSelected) {
        list.add(polylineId);
      }
    }
    notifyListeners();
  }

  void toggleCircleSelected(CircleId circleId, ElementType type) {

    var circleList = getCircleList(type);
    if (circleList.contains(circleId)) {
      circleList.remove(circleId);
    } else {
      if (circleList.isEmpty || _letMultipleItemsSelected) {
        circleList.add(circleId);
      }
    }
    notifyListeners();
  }

  void setSections(Set<PolylineId>? sections) {
    if (sections != null) {
      _currentSelectedSections = sections;
    }
  }

  void setCatchments(Set<CircleId>? catchments) {
    if (catchments != null) {
      _currentSelectedCatchments = catchments;
    }
  }

  void setRegisters(Set<CircleId>? registers) {
    if (registers != null) {
      _currentSelectedRegisters = registers;
    }
  }

  void setLots(Set<PolylineId>? lots) {
    if (lots != null) {
      _currentSelectedLots = lots;
    }
  }

  void saveInitialSelections(
      Set<PolylineId>? sections,
      Set<CircleId>? registers,
      Set<CircleId>? catchments,
      Set<PolylineId>? lots,
      LatLng position) {
    _initialSelectedSections = Set<PolylineId>.from(sections ?? {});
    _initialSelectedRegisters = Set<CircleId>.from(registers ?? {});
    _initialSelectedCatchments = Set<CircleId>.from(catchments ?? {});
    _initialSelectedLots = Set<PolylineId>.from(lots ?? {});
    _initialInspectionPosition = position;
    _currentInspectionPosition = position;
    setLots(lots);
    setSections(sections);
    setCatchments(catchments);
    setRegisters(registers);
    setInspectionPosition(position);
    notifyListeners();
  }

  void restoreInitialValues() {
    _currentSelectedSections = Set<PolylineId>.from(_initialSelectedSections);
    _currentSelectedRegisters = Set<CircleId>.from(_initialSelectedRegisters);
    _currentSelectedCatchments = Set<CircleId>.from(_initialSelectedCatchments);
    _currentSelectedLots = Set<PolylineId>.from(_initialSelectedLots);
    _currentInspectionPosition = _initialInspectionPosition;
    notifyListeners();
  }

  void restoreLocation() {
    _currentInspectionPosition = _initialInspectionPosition;
  }

  void saveCurrentSelectionsAsInitial() {
    _initialSelectedSections = Set<PolylineId>.from(_currentSelectedSections);
    _initialSelectedRegisters = Set<CircleId>.from(_currentSelectedRegisters);
    _initialSelectedCatchments = Set<CircleId>.from(_currentSelectedCatchments);
    _initialSelectedLots = Set<PolylineId>.from(_currentSelectedLots);
    _initialInspectionPosition = _currentInspectionPosition;
    notifyListeners();
  }

  void saveCurrentPositionAsInitial() {
    _initialInspectionPosition = _currentInspectionPosition;
    notifyListeners();
  }

  bool isPolylineSelected(PolylineId polylineId, ElementType type) {
    var polylineList = getPolylineList(type);
    return polylineList.contains(polylineId);
  }

  bool isSomePolylineSelected(ElementType type) {
    var polylineList = getPolylineList(type);
    return polylineList.isNotEmpty;
  }

  bool isCircleSelected(CircleId circleId, ElementType type) {
    var circleList = getCircleList(type);
    return circleList.contains(circleId);
  }

  bool isSomeCircleSelected(ElementType type) {
    var circleList = getCircleList(type);
    return circleList.isNotEmpty;
  }

  bool isSomeElementSelected() {
    return _currentSelectedSections.isNotEmpty ||
        _currentSelectedCatchments.isNotEmpty ||
        _currentSelectedRegisters.isNotEmpty ||
        _currentSelectedLots.isNotEmpty;
  }

  Set<CircleId> getCircleList(ElementType type) {
    return switch (type) {
      ElementType.register => _currentSelectedRegisters,
      ElementType.catchment => _currentSelectedCatchments,
      _ => Set()
    };
  }

  Set<PolylineId> getPolylineList(ElementType type) {
    return switch (type) {
      ElementType.section => _currentSelectedSections,
      ElementType.lot => _currentSelectedLots,
      _ => Set()
    };
  }

  void clearAllElements() {
    _currentSelectedCatchments.clear();
    _currentSelectedSections.clear();
    _currentSelectedRegisters.clear();
    _currentSelectedLots.clear();
    _initialSelectedSections.clear();
    _initialSelectedRegisters.clear();
    _initialSelectedCatchments.clear();
    _initialSelectedLots.clear();
  }

  void reset() {
    clearAllElements();
    _letMultipleItemsSelected = false;
    _initialInspectionPosition = const LatLng(0, 0);
    _currentInspectionPosition = const LatLng(0, 0);
  }
}
