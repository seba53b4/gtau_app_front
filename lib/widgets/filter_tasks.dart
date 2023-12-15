import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtau_app_front/models/enums/message_type.dart';
import 'package:gtau_app_front/models/task_status.dart';
import 'package:gtau_app_front/widgets/text_field_filter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/task_filters_provider.dart';
import '../providers/user_provider.dart';
import '../viewmodels/task_list_viewmodel.dart';
import 'common/box_container.dart';
import 'common/custom_elevated_button.dart';
import 'dropdown_button_filter.dart';

class FilterTasks extends StatefulWidget {
  const FilterTasks({
    super.key,
  });

  @override
  State<FilterTasks> createState() => _FilterTasksState();
}

class _FilterTasksState extends State<FilterTasks> {
  double widthRow = 640;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  _ResetScrollPosition() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble("position", 0.0);
  }

  void _SetFilteredValue(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("isFiltered", value);
  }

  Future<bool> _GetFilteredValue() async {
    final SharedPreferences prefs = await _prefs;
    return (prefs.getBool("isFiltered") ?? false);
  }

  Future<bool> _ResetPrefs() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.clear();
  }

  Future resetTaskList() async {
    final userName =
        Provider.of<TaskFilterProvider>(context, listen: false).userNameFilter;
    final status =
        Provider.of<TaskFilterProvider>(context, listen: false).lastStatus;
    final taskListViewModel =
        Provider.of<TaskListViewModel>(context, listen: false);
    taskListViewModel.clearListByStatus(status!);
    await taskListViewModel.initializeTasks(context, status, userName);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final userProvider = context.read<UserProvider>();
    final filterProvider = Provider.of<TaskFilterProvider>(context);
    return Scaffold(
      appBar: AppBar(
          title: Padding(
        padding: const EdgeInsets.only(right: 80),
        child: Center(
            child: Text(
          appLocalizations.filter_task_title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: kIsWeb ? 18 : 22),
        )),
      )),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BoxContainer(
            width: widthRow,
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(height: 8),
                  DropdownButtonFilter(
                    suggestions: filterProvider.inspectionType,
                    valueSetter: filterProvider.setInspectionTypeFilter,
                    dropdownValue: filterProvider.inspectionTypeFilter ??
                        filterProvider.inspectionType.first.value,
                    label: appLocalizations.inspection_type,
                    enabled: true,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFilter(
                    suggestions: filterProvider.suggestionsUsers,
                    valueSetter: filterProvider.setUserNameFilter,
                    dropdownValue: !userProvider.isAdmin!
                        ? userProvider.userName!
                        : (filterProvider.userNameFilter ??
                            filterProvider.suggestionsUsers.first.value),
                    label: appLocalizations.user,
                    enabled: userProvider.isAdmin! ? true : false,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFilter(
                    suggestions: filterProvider.suggestionsStatus,
                    valueSetter: filterProvider.setLastStatus,
                    dropdownValue: filterProvider.statusFilter ??
                        filterProvider.suggestionsStatus.first.value,
                    label: appLocalizations.editTaskPage_statusTitle,
                    enabled: true,
                  ),
                  const SizedBox(height: 16),
                  TextFieldFilter(
                    valueSetter: filterProvider.setWorkNumberFilter,
                    value: filterProvider.workNumberFilter ?? "",
                    label: appLocalizations.createTaskPage_numberWorkTitle,
                  ),
                  const SizedBox(height: 16),
                  TextFieldFilter(
                      valueSetter: filterProvider.setApplicantFilter,
                      value: filterProvider.applicantFilter ?? "",
                      label: appLocalizations.createTaskPage_solicitantTitle),
                  const SizedBox(height: 16),
                  TextFieldFilter(
                      valueSetter: filterProvider.setLocationFilter,
                      value: filterProvider.locationFilter ?? "",
                      label:
                          appLocalizations.createTaskPage_selectUbicationTitle),
                  const SizedBox(height: 16),
                  TextFieldFilter(
                      valueSetter: filterProvider.setDescriptionFilter,
                      value: filterProvider.descriptionFilter ?? "",
                      label: appLocalizations.default_descriptionTitle),
                  const SizedBox(height: 16),
                  TextFieldFilter(
                      valueSetter: filterProvider.setLengthFilter,
                      value: filterProvider.lengthFilter ?? "",
                      label: appLocalizations.createTaskPage_longitudeTitle),
                  const SizedBox(height: 16),
                  TextFieldFilter(
                      valueSetter: filterProvider.setMaterialFilter,
                      value: filterProvider.materialFilter ?? "",
                      label: appLocalizations.createTaskPage_materialTitle),
                  const SizedBox(height: 16),
                  TextFieldFilter(
                      valueSetter: filterProvider.setObservationsFilter,
                      value: filterProvider.observationsFilter ?? "",
                      label: appLocalizations.createTaskPage_observationsTitle),
                  const SizedBox(height: 16),
                  TextFieldFilter(
                      valueSetter: filterProvider.setConclusionsFilter,
                      value: filterProvider.conclusionsFilter ?? "",
                      label: appLocalizations.createTaskPage_conclusionsTitle),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 50,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomElevatedButton(
                                  onPressed: () {
                                    var taskFilterProvider =
                                        context.read<TaskFilterProvider>();
                                    taskFilterProvider
                                        .resetFilters(userProvider.isAdmin!);
                                    taskFilterProvider.setLastStatus(
                                        TaskStatus.Pending.value);
                                    _ResetPrefs();
                                    resetTaskList();
                                    Navigator.of(context).pop();
                                  },
                                  messageType: MessageType.error,
                                  text: appLocalizations.buttonCleanLabel,
                                ),
                                const SizedBox(width: 10.0),
                                CustomElevatedButton(
                                  onPressed: () {
                                    _ResetScrollPosition();
                                    _SetFilteredValue(true);
                                    context.read<TaskFilterProvider>().search();
                                    updateTaskList();
                                    Navigator.of(context).pop();
                                  },
                                  text: appLocalizations.buttonApplyLabel,
                                ),
                              ]),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void updateTaskList() async {
    final filterProvider =
        Provider.of<TaskFilterProvider>(context, listen: false);
    final taskListViewModel =
        Provider.of<TaskListViewModel>(context, listen: false);
    taskListViewModel.clearListByStatus(filterProvider.statusFilter!);
    await taskListViewModel.fetchTasksFromFilters(context,
        filterProvider.statusFilter!, filterProvider.buildSearchBody());
  }
}
