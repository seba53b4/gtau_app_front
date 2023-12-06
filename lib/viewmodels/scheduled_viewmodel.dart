import 'package:flutter/cupertino.dart';
import 'package:gtau_app_front/models/scheduled/register_scheduled.dart';
import 'package:gtau_app_front/models/scheduled/section_scheduled.dart';
import 'package:gtau_app_front/services/scheduled_service.dart';

import '../models/scheduled/catchment_scheduled.dart';

class ScheduledViewModel extends ChangeNotifier {
  final ScheduledService _scheduledService = ScheduledService();

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
}
