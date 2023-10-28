import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/enums/element_type.dart';

class SelectedItemsProvider with ChangeNotifier {
  bool _letMultipleItemsSelected = false;

  bool get letMultipleItemsSelected => _letMultipleItemsSelected;

  Set<PolylineId> _selectedSections = {};

  Set<PolylineId> get selectedPolylines => _selectedSections;

  Set<CircleId> _selectedRegisters = {};

  Set<CircleId> get selectedRegisters => _selectedRegisters;

  Set<CircleId> _selectedCatchments = {};

  Set<CircleId> get selectedCatchments => _selectedCatchments;

  Set<PolylineId> _selectedLots = {};

  Set<PolylineId> get selectedLots => _selectedLots;

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

  void setLots(Set<PolylineId>? lots) {
    if (lots != null) {
      _selectedLots = lots;
      notifyListeners();
    }
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
    return _selectedSections.isNotEmpty ||
        _selectedCatchments.isNotEmpty ||
        _selectedRegisters.isNotEmpty ||
        _selectedLots.isNotEmpty;
  }

  Set<CircleId> getCircleList(ElementType type) {
    return switch (type) {
      ElementType.register => _selectedRegisters,
      ElementType.catchment => _selectedCatchments,
      _ => Set()
    };
  }

  Set<PolylineId> getPolylineList(ElementType type) {
    return switch (type) {
      ElementType.section => _selectedSections,
      ElementType.lot => _selectedLots,
      _ => Set()
    };
  }

  void clearAll() {
    _selectedCatchments.clear();
    _selectedSections.clear();
    _selectedRegisters.clear();
    _selectedLots.clear();
  }

  void reset() {
    clearAll();
    _letMultipleItemsSelected = false;
  }
}
