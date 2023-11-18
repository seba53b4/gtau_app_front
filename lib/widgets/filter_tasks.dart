import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtau_app_front/widgets/text_field_filter.dart';
import 'package:provider/provider.dart';

import '../providers/task_filters_provider.dart';
import '../viewmodels/task_list_viewmodel.dart';
import 'dropdown_button_filter.dart';

class FilterTasks extends StatefulWidget {
  const FilterTasks({
    super.key,
  });

  @override
  State<FilterTasks> createState() => _FilterTasksState();
}

class _FilterTasksState extends State<FilterTasks> {
  @override
  Widget build(BuildContext context) {
    final filterProvider = Provider.of<TaskFilterProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text("Filtrar inspecciones")),
      body: SizedBox(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(kIsWeb ? 100.0 : 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              DropdownButtonFilter(
                suggestions: filterProvider.inspectionType,
                valueSetter: filterProvider.setInspectionTypeFilter,
                dropdownValue: filterProvider.inspectionTypeFilter ??
                    filterProvider.inspectionType.first.value,
                label: "Tipo de inspección:",
              ),
              const SizedBox(height: 16),
              DropdownButtonFilter(
                suggestions: filterProvider.suggestionsUsers,
                valueSetter: filterProvider.setUserNameFilter,
                dropdownValue: filterProvider.userNameFilter ??
                    filterProvider.suggestionsUsers.first.value,
                label: "Usuario:",
              ),
              const SizedBox(height: 16),
              DropdownButtonFilter(
                suggestions: filterProvider.suggestionsStatus,
                valueSetter: filterProvider.setLastStatus,
                dropdownValue: filterProvider.statusFilter ??
                    filterProvider.suggestionsStatus.first.value,
                label: "Estado:",
              ),
              const SizedBox(height: 16),
              TextFieldFilter(
                valueSetter: filterProvider.setWorkNumberFilter,
                value: filterProvider.workNumberFilter ?? "",
                label: "Número de trabajo:",
              ),
              const SizedBox(height: 16),
              TextFieldFilter(
                  valueSetter: filterProvider.setApplicantFilter,
                  value: filterProvider.applicantFilter ?? "",
                  label: "Solicitante:"),
              const SizedBox(height: 16),
              TextFieldFilter(
                  valueSetter: filterProvider.setLocationFilter,
                  value: filterProvider.locationFilter ?? "",
                  label: "Ubicación:"),
              const SizedBox(height: 16),
              TextFieldFilter(
                  valueSetter: filterProvider.setDescriptionFilter,
                  value: filterProvider.descriptionFilter ?? "",
                  label: "Descripción:"),
              const SizedBox(height: 16),
              TextFieldFilter(
                  valueSetter: filterProvider.setLengthFilter,
                  value: filterProvider.lengthFilter ?? "",
                  label: "Longitud:"),
              const SizedBox(height: 16),
              TextFieldFilter(
                  valueSetter: filterProvider.setMaterialFilter,
                  value: filterProvider.materialFilter ?? "",
                  label: "Material:"),
              const SizedBox(height: 16),
              TextFieldFilter(
                  valueSetter: filterProvider.setObservationsFilter,
                  value: filterProvider.observationsFilter ?? "",
                  label: "Observaciones:"),
              const SizedBox(height: 16),
              TextFieldFilter(
                  valueSetter: filterProvider.setConclusionsFilter,
                  value: filterProvider.conclusionsFilter ?? "",
                  label: "Conclusiones:"),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 50,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () {
                                context
                                    .read<TaskFilterProvider>()
                                    .resetFilters();
                                Navigator.of(context).pop();
                              },
                              child: Text(AppLocalizations.of(context)!
                                  .buttonCleanLabel),
                            ),
                            const SizedBox(width: 10.0),
                            ElevatedButton(
                              onPressed: () {
                                updateTaskList();
                                Navigator.of(context).pop();
                              },
                              child: Text(AppLocalizations.of(context)!
                                  .buttonApplyLabel),
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
