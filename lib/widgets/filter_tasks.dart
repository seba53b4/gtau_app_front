import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtau_app_front/models/enums/message_type.dart';
import 'package:gtau_app_front/models/task_status.dart';
import 'package:gtau_app_front/widgets/text_field_filter.dart';
import 'package:provider/provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserProvider>();
    final filterProvider = Provider.of<TaskFilterProvider>(context);
    return Scaffold(
      appBar: AppBar(
          title: Text(
        "Filtrar tareas",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: kIsWeb ? 18 : 22),
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
                    label: "Tipo de inspección",
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
                    label: "Usuario",
                    enabled: userProvider.isAdmin! ? true : false,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFilter(
                    suggestions: filterProvider.suggestionsStatus,
                    valueSetter: filterProvider.setLastStatus,
                    dropdownValue: filterProvider.statusFilter ??
                        filterProvider.suggestionsStatus.first.value,
                    label: "Estado",
                    enabled: true,
                  ),
                  const SizedBox(height: 16),
                  TextFieldFilter(
                    valueSetter: filterProvider.setWorkNumberFilter,
                    value: filterProvider.workNumberFilter ?? "",
                    label: "Número de trabajo",
                  ),
                  const SizedBox(height: 16),
                  TextFieldFilter(
                      valueSetter: filterProvider.setApplicantFilter,
                      value: filterProvider.applicantFilter ?? "",
                      label: "Solicitante"),
                  const SizedBox(height: 16),
                  TextFieldFilter(
                      valueSetter: filterProvider.setLocationFilter,
                      value: filterProvider.locationFilter ?? "",
                      label: "Ubicación"),
                  const SizedBox(height: 16),
                  TextFieldFilter(
                      valueSetter: filterProvider.setDescriptionFilter,
                      value: filterProvider.descriptionFilter ?? "",
                      label: "Descripción"),
                  const SizedBox(height: 16),
                  TextFieldFilter(
                      valueSetter: filterProvider.setLengthFilter,
                      value: filterProvider.lengthFilter ?? "",
                      label: "Longitud"),
                  const SizedBox(height: 16),
                  TextFieldFilter(
                      valueSetter: filterProvider.setMaterialFilter,
                      value: filterProvider.materialFilter ?? "",
                      label: "Material"),
                  const SizedBox(height: 16),
                  TextFieldFilter(
                      valueSetter: filterProvider.setObservationsFilter,
                      value: filterProvider.observationsFilter ?? "",
                      label: "Observaciones"),
                  const SizedBox(height: 16),
                  TextFieldFilter(
                      valueSetter: filterProvider.setConclusionsFilter,
                      value: filterProvider.conclusionsFilter ?? "",
                      label: "Conclusiones"),
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

                                    Navigator.of(context).pop();
                                  },
                                  messageType: MessageType.error,
                                  text: AppLocalizations.of(context)!
                                      .buttonCleanLabel,
                                ),
                                const SizedBox(width: 10.0),
                                CustomElevatedButton(
                                  onPressed: () {
                                    context.read<TaskFilterProvider>().search();
                                    updateTaskList();
                                    Navigator.of(context).pop();
                                  },
                                  text: AppLocalizations.of(context)!
                                      .buttonApplyLabel,
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
