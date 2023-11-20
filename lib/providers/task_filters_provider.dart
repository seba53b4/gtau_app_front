import 'package:flutter/foundation.dart';

import '../models/task_status.dart';
import '../models/value_label.dart';

class TaskFilterProvider with ChangeNotifier {
  String? _userNameFilter;

  String? get userNameFilter => _userNameFilter;

  void setUserNameFilter(String? newName) {
    _userNameFilter = newName;
  }

  String? _statusFilter = TaskStatus.Pending.value;

  String? get statusFilter => _statusFilter;

  void setLastStatus(String lastStatus) {
    _statusFilter = lastStatus;
  }

  String? _inspectionTypeFilter;

  String? get inspectionTypeFilter => _inspectionTypeFilter;

  void setInspectionTypeFilter(String? newInspectionType) {
    _inspectionTypeFilter = newInspectionType;
  }

  String? _workNumberFilter;

  String? get workNumberFilter => _workNumberFilter;

  void setWorkNumberFilter(String? newWorkNumber) {
    _workNumberFilter = newWorkNumber;
  }

  DateTime? _addDateFilter;

  DateTime? get addDateFilter => _addDateFilter;

  void setAddDateFilter(DateTime? newAddDate) {
    _addDateFilter = newAddDate;
  }

  String? _applicantFilter;

  String? get applicantFilter => _applicantFilter;

  void setApplicantFilter(String? newApplicant) {
    _applicantFilter = newApplicant;
  }

  String? _locationFilter;

  String? get locationFilter => _locationFilter;

  void setLocationFilter(String? newLocation) {
    _locationFilter = newLocation;
  }

  String? _descriptionFilter;

  String? get descriptionFilter => _descriptionFilter;

  void setDescriptionFilter(String? newDescription) {
    _descriptionFilter = newDescription;
  }

  String? _lengthFilter;

  String? get lengthFilter => _lengthFilter;

  void setLengthFilter(String? newLength) {
    _lengthFilter = newLength;
  }

  String? _materialFilter;

  String? get materialFilter => _materialFilter;

  void setMaterialFilter(String? newMaterial) {
    _materialFilter = newMaterial;
  }

  String? _observationsFilter;

  String? get observationsFilter => _observationsFilter;

  void setObservationsFilter(String? newObservations) {
    _observationsFilter = newObservations;
  }

  String? _conclusionsFilter;

  String? get conclusionsFilter => _conclusionsFilter;

  void setConclusionsFilter(String? newConclusions) {
    _conclusionsFilter = newConclusions;
  }

  Map<String, dynamic> buildSearchBody() {
    final List<Map<String, dynamic>> searchCriteriaList = [];

    void addFilterIfValid(String? filterValue, String op, String filterKey) {
      if (filterValue != null && filterValue.isNotEmpty) {
        searchCriteriaList.add(
            {"filterKey": filterKey, "operation": op, "value": filterValue});
      }
    }

    void addDateFilterIfValid(DateTime? filterValue, String filterKey) {
      if (filterValue != null) {
        searchCriteriaList.add(
            {"filterKey": filterKey, "operation": "eq", "value": filterValue});
      }
    }

    addFilterIfValid(_userNameFilter, "eq", "username");
    addFilterIfValid(_statusFilter, "eq", "status");
    addFilterIfValid(_inspectionTypeFilter, "eq", "inspectionType");
    addFilterIfValid(_workNumberFilter, "cn", "workNumber");
    addDateFilterIfValid(_addDateFilter, "addDate");
    addFilterIfValid(_applicantFilter, "cn", "applicant");
    addFilterIfValid(_locationFilter, "cn", "location");
    addFilterIfValid(_descriptionFilter, "cn", "description");
    addFilterIfValid(_lengthFilter, "eq", "length");
    addFilterIfValid(_materialFilter, "cn", "material");
    addFilterIfValid(_observationsFilter, "cn", "observations");
    addFilterIfValid(_conclusionsFilter, "cn", "conclusions");

    return {
      "dataOption": "all", // Esto es un and, también puede ser any (or)
      "searchCriteriaList": searchCriteriaList,
    };
  }

  void resetFilters() {
    _userNameFilter = null;
    _statusFilter = null;
    _inspectionTypeFilter = null;
    _workNumberFilter = null;
    _addDateFilter = null;
    _applicantFilter = null;
    _locationFilter = null;
    _descriptionFilter = null;
    _lengthFilter = null;
    _materialFilter = null;
    _observationsFilter = null;
    _conclusionsFilter = null;
    notifyListeners();
  }

  final List<ValueLabel> _suggestionsUsers = [
    "gtau-admin",
    "gtau-oper",
    "no-asignada"
  ].map((e) => ValueLabel(e, e)).toList();

  List<ValueLabel> get suggestionsUsers => _suggestionsUsers;

  final List<ValueLabel> _suggestionsStatus = [
    ValueLabel("Pendiente", TaskStatus.Pending.value),
    ValueLabel("En curso", TaskStatus.Doing.value),
    ValueLabel("Bloqueadas", TaskStatus.Blocked.value),
    ValueLabel("Terminadas", TaskStatus.Done.value)
  ];

  List<ValueLabel> get suggestionsStatus => _suggestionsStatus;

  final List<ValueLabel> _inspectionTypes = [
    ValueLabel("Inspección", "INSPECTION"),
    ValueLabel("Programada", "SCHEDULED"),
  ];

  List<ValueLabel> get inspectionType => _inspectionTypes;

  int getCurrentIndex() {
    return statusFilter == null
        ? 0
        : suggestionsStatus.map((e) => e.value).toList().indexOf(statusFilter!);
  }

  void search() {
    notifyListeners();
  }
}
