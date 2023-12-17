import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gtau_app_front/models/scheduled/register_scheduled.dart';
import 'package:gtau_app_front/models/scheduled/section_scheduled.dart';
import 'package:gtau_app_front/services/scheduled_service.dart';

import '../models/scheduled/catchment_scheduled.dart';
import '../utils/map_functions.dart';

class ScheduledViewModel extends ChangeNotifier {
  final ScheduledService _scheduledService = ScheduledService();

  static const LatLng initLocation = LatLng(-34.88773, -56.13955);

  List<CatchmentScheduled> _catchments = [];

  List<CatchmentScheduled> get catchments => _catchments;

  List<SectionScheduled> _sections = [];

  List<SectionScheduled> get sections => _sections;

  List<RegisterScheduled> _registers = [];

  List<RegisterScheduled> get registers => _registers;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  bool _error = false;

  bool get error => _error;

  LatLng _initPosition = LatLng(-34.88773, -56.13955);

  LatLng get initPosition => _initPosition;

  void setInitPosition(LatLng? pos) {
    if (pos != null && initLocation.longitude != pos.longitude ||
        initLocation.latitude != pos!.latitude) {
      _initPosition = pos;
    }
  }

  reset() {
    _catchments.clear();
    _sections.clear();
    _registers.clear();
    _error = false;
    _isLoading = false;
  }

  Future<ScheduledElements?> fetchScheduledElements(
      String token, int scheduledId) async {
    try {
      _isLoading = true;
      _error = false;
      ScheduledElements? entities =
          await _scheduledService.fetchTaskScheduledEntities(
        token,
        scheduledId,
      );

      if (entities != null) {
        _catchments = entities.catchments;
        _sections = entities.sections;
        _registers = entities.registers;

        _isLoading = false;
      } else {
        _error = true;
      }

      Future.microtask(() {
        _isLoading = false;
        notifyListeners();
      });

      return entities;
    } catch (error) {
      _isLoading = false;
      _error = true;
      Future.microtask(() {
        notifyListeners();
      });
      print('Error in fetchScheduledElements: $error');
    }
    return null;
  }

  Future<SectionScheduled?> fetchSectionScheduledById(
      String token, int scheduledId, int sectionId) async {
    try {
      _isLoading = true;
      _error = false;
      SectionScheduled? sectionScheduledResp = await _scheduledService
          .fetchSectionScheduledById(token, scheduledId, sectionId);

      if (sectionScheduledResp != null) {
        _isLoading = false;
      } else {
        _error = true;
      }

      Future.microtask(() {
        _isLoading = false;
        notifyListeners();
      });

      return sectionScheduledResp;
    } catch (error) {
      _isLoading = false;
      _error = true;
      Future.microtask(() {
        notifyListeners();
      });
      print('Error in fetchScheduledElements: $error');
    }
    return null;
  }

  Future<bool> updateSectionScheduled(String token, int scheduledId,
      int sectionId, Map<String, dynamic> body) async {
    try {
      _isLoading = true;
      _error = false;
      final response = await _scheduledService.updateSectionScheduled(
          token, scheduledId, sectionId, body);
      _isLoading = false;
      return response;
    } catch (error) {
      _isLoading = false;
      _error = true;
      if (kDebugMode) {
        print('Error in updateSectionScheduledById: $error');
      }
      rethrow;
    }
  }

  Future<RegisterScheduled?> fetchRegisterScheduledById(
      String token, int scheduledId, int registerId) async {
    try {
      _isLoading = true;
      _error = false;

      RegisterScheduled? registerScheduledResp = await _scheduledService
          .fetchRegisterScheduledById(token, scheduledId, registerId);

      if (registerScheduledResp != null) {
        _isLoading = false;
      } else {
        _error = true;
      }

      Future.microtask(() {
        _isLoading = false;
        notifyListeners();
      });

      return registerScheduledResp;
    } catch (error) {
      _isLoading = false;
      _error = true;
      Future.microtask(() {
        notifyListeners();
      });
      print('Error in fetchRegisterScheduledById: $error');
    }
    return null;
  }

  Future<bool> updateRegisterScheduled(String token, int scheduledId,
      int registerId, Map<String, dynamic> body) async {
    try {
      _isLoading = true;
      _error = false;
      final response = await _scheduledService.updateRegisterScheduled(
          token, scheduledId, registerId, body);
      _isLoading = false;
      return response;
    } catch (error) {
      _isLoading = false;
      _error = true;
      if (kDebugMode) {
        print('Error in updateRegisterScheduled: $error');
      }
      rethrow;
    }
  }

  Future<CatchmentScheduled?> fetchCatchmentScheduledById(
      String token, int scheduledId, int catchmentId) async {
    try {
      _isLoading = true;
      _error = false;
      CatchmentScheduled? catchmentScheduledResp = await _scheduledService
          .fetchCatchmentScheduledById(token, scheduledId, catchmentId);

      if (catchmentScheduledResp != null) {
        _isLoading = false;
      } else {
        _error = true;
      }

      Future.microtask(() {
        _isLoading = false;
        notifyListeners();
      });

      return catchmentScheduledResp;
    } catch (error) {
      _isLoading = false;
      _error = true;
      Future.microtask(() {
        notifyListeners();
      });
      print('Error in fetchCatchmentScheduledById: $error');
    }
    return null;
  }

  Future<bool> updateCatchmentScheduled(String token, int scheduledId,
      int catchmentId, Map<String, dynamic> body) async {
    try {
      _isLoading = true;
      _error = false;
      final response = await _scheduledService.updateCatchmentScheduled(
          token, scheduledId, catchmentId, body);
      _isLoading = false;
      return response;
    } catch (error) {
      _isLoading = false;
      _error = true;
      if (kDebugMode) {
        print('Error in updateCatchmentScheduled: $error');
      }
      rethrow;
    }
  }

  Future<LatLng?> getRandomPosition(
      Set<Polyline> polylines, Set<Circle> circles) async {
    try {
      _isLoading = true;
      _error = false;
      notifyListeners();
      LatLng? pos = getRandomPointOfMap(polylines, circles);
      _isLoading = false;
      return pos;
    } catch (error) {
      _isLoading = false;
      _error = true;
      if (kDebugMode) {
        print('Error in getRandomPosition: $error');
      }
      rethrow;
    } finally {
      notifyListeners();
    }
  }
}
