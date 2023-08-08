import 'package:flutter/material.dart';
import 'package:gtau_app_front/models/task_status.dart';
import 'package:gtau_app_front/providers/user_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtau_app_front/widgets/common/customMessageDialog.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../viewmodels/task_list_viewmodel.dart';
import '../widgets/common/customDialog.dart';

class TaskCreationScreen extends StatefulWidget {
  var type = 'inspection';
  bool detail = false;
  int? idTask = 0;
  TaskCreationScreen(
      {super.key, required this.type, this.detail = false, this.idTask = 0});

  @override
  _TaskCreationScreenState createState() => _TaskCreationScreenState();
}

class _TaskCreationScreenState extends State<TaskCreationScreen> {
  late Task task;
  late DateTime? startDate;
  late DateTime? releasedDate;
  int selectedIndex = 0;
  String userAssigned = "not-assigned";
  late String taskStatus = 'PENDING';
  final descriptionController = TextEditingController();
  final numWorkController = TextEditingController();
  final locationController = TextEditingController();
  final scheduledNumberController = TextEditingController();
  final contactController = TextEditingController();
  final applicantController = TextEditingController();
  final userAssignedController = TextEditingController();
  final lengthController = TextEditingController();
  final materialController = TextEditingController();
  final observationsController = TextEditingController();
  final conclusionsController = TextEditingController();
  final addDateController = TextEditingController();
  final releasedDateController = TextEditingController();
  final String formatDate = 'dd-MM-yyyy';

  String numOrder = "";

  void reset() {
    descriptionController.text = '';
    numWorkController.text = '';
    locationController.text = '';
    scheduledNumberController.text = '';
    contactController.text = '';
    applicantController.text = '';
    userAssignedController.text = '';
    lengthController.text = '';
    materialController.text = '';
    observationsController.text = '';
    conclusionsController.text = '';
    addDateController.text = '';
    releasedDateController.text = '';
    setState(() {
      userAssigned = "not-assigned";
    });
  }

  Future<bool> _fetchTask() async {
    final token = Provider.of<UserProvider>(context, listen: false).getToken;
    final taskListViewModel =
        Provider.of<TaskListViewModel>(context, listen: false);

    try {
      final responseTask =
          await taskListViewModel.fetchTask(token, widget.idTask!);

      if (responseTask != null) {
        setState(() {
          task = responseTask;
        });
      }
      numWorkController.text = task.workNumber!;
      descriptionController.text = task.description!;
      applicantController.text = task.applicant!;
      locationController.text = task.location!;
      userAssignedController.text = task.user!;
      lengthController.text = task.length ?? '';
      materialController.text = task.material ?? '';
      conclusionsController.text = task.conclusions ?? '';
      observationsController.text = task.observations ?? '';
      startDate = task.addDate!;
      taskStatus = task.status!;
      if (task.releasedDate != null) {
        releasedDate = task.releasedDate!;
        releasedDateController.text =
            DateFormat(formatDate).format(task.releasedDate!).toString();
      }
      addDateController.text =
          DateFormat(formatDate).format(task.addDate!).toString();
      return true;
    } catch (error) {
      print(error);
      throw Exception('Error al obtener los datos');
    }
  }

  Future<bool> _createTask(Map<String, dynamic> body) async {
    final token = Provider.of<UserProvider>(context, listen: false).getToken;
    final taskListViewModel = Provider.of<TaskListViewModel>(context, listen: false);
    try {
      final response = await taskListViewModel.createTask(token!, body);
      if (response) {
        print('Tarea ha sido creada correctamente');
        showMessageDialog(DialogMessageType.success);
        return true;
      } else {
        showMessageDialog(DialogMessageType.error);
        print('No se pudieron traer datos');
        return false;
      }
    } catch (error) {
      print(error);
      throw Exception('Error al obtener los datos');
    }
  }

  Future<bool> _updateTask(Map<String, dynamic> body) async {
    final token = Provider.of<UserProvider>(context, listen: false).getToken;

    final taskListViewModel =
        Provider.of<TaskListViewModel>(context, listen: false);

    try {
      final response =
          await taskListViewModel.updateTask(token!, widget.idTask!, body);

      if (response) {
        print('Tarea ha sido actualizada correctamente');
        showMessageDialog(DialogMessageType.success);
        return true;
      } else {
        print('No se pudieron traer datos');
        showMessageDialog(DialogMessageType.error);
        return false;
      }
    } catch (error) {
      print(error);
      throw Exception('Error al obtener los datos');
    }
  }

  void showMessageDialog(DialogMessageType type) {
    showCustomMessageDialog(
        context: context, messageType: type, onAcceptPressed: () {});
  }

  String formattedDateToUpdate(String dateString) {
    DateFormat inputFormat = DateFormat(formatDate);
    DateTime date = inputFormat.parse(dateString);

    String formattedDate = date.toUtc().toIso8601String();

    return formattedDate;
  }

  Future<void> initializeTask() async {
    await _fetchTask();
  }

  @override
  void dispose() {
    descriptionController.dispose();
    numWorkController.dispose();
    locationController.dispose();
    scheduledNumberController.dispose();
    contactController.dispose();
    applicantController.dispose();
    userAssignedController.dispose();
    lengthController.dispose();
    materialController.dispose();
    observationsController.dispose();
    conclusionsController.dispose();
    addDateController.dispose();
    releasedDateController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.detail) {
      widget.type == 'inspection' ? selectedIndex = 1 : selectedIndex = 0;
      releasedDate = DateTime.now();
      initializeTask();
    } else {
      startDate = DateTime.now();
    }
  }

  void handleStartDateChange(DateTime date) {
    setState(() {
      startDate = date;
    });
    addDateController.text = DateFormat(formatDate).format(date);
  }

  void handleReleasedDateChange(DateTime dateReleased) {
    setState(() {
      releasedDate = dateReleased;
    });
    releasedDateController.text = DateFormat(formatDate).format(dateReleased);
  }

  void handleSubmit() {
    if (selectedIndex == 1) {
      showCustomDialog(
        context: context,
        title: AppLocalizations.of(context)!.dialogWarning,
        content: AppLocalizations.of(context)!.dialogContent,
        onDisablePressed: () {
          Navigator.of(context).pop();
        },
        onEnablePressed: () {
          handleAcceptOnShowDialogCreateTask();
          Navigator.of(context).pop();
        },
        acceptButtonLabel: AppLocalizations.of(context)!.dialogAcceptButton,
        cancelbuttonLabel: AppLocalizations.of(context)!.dialogCancelButton,
      );
    } else {
      print(
          'Programada: ${scheduledNumberController.text} Descripcion: ${descriptionController.text}');
    }
  }

  Map<String, dynamic> createBodyToCreate() {
    late String addDateUpdated = formattedDateToUpdate(addDateController.text);
    final Map<String, dynamic> requestBody = {
      "status": taskStatus,
      "inspectionType": "inspectionType Default",
      "workNumber": numWorkController.text,
      "addDate": addDateUpdated,
      "applicant": applicantController.text,
      "location": locationController.text,
      "description": descriptionController.text,
      "user": userAssigned,
    };
    return requestBody;
  }

  Map<String, dynamic> createBodyToUpdate() {
    late String addDateUpdated = formattedDateToUpdate(addDateController.text);
    final Map<String, dynamic> requestBody = {
      "status": taskStatus,
      "inspectionType": task.inspectionType,
      "workNumber": numWorkController.text,
      "addDate": addDateUpdated,
      "applicant": applicantController.text,
      "location": locationController.text,
      "description": descriptionController.text,
      "releasedDate": releasedDate == null
          ? formattedDateToUpdate(releasedDateController.text)
          : null,
      "user": userAssignedController.text,
      "length": lengthController.text,
      "material": materialController.text,
      "observations": observationsController.text,
      "conclusions": conclusionsController.text
    };
    return requestBody;
  }

  void handleAcceptOnShowDialogEditTask() async {
    Map<String, dynamic> requestBody = createBodyToUpdate();
    bool isUpdated = await _updateTask(requestBody);
    if (isUpdated) {
      reset();
    }
  }

  void handleAcceptOnShowDialogCreateTask() async {
    Map<String, dynamic> requestBody = createBodyToCreate();
    bool isUpdated = await _createTask(requestBody);
    if (isUpdated) {
      reset();
    }
  }

  void handleEditTask() {
    showCustomDialog(
      context: context,
      title: AppLocalizations.of(context)!.dialogWarning,
      content: AppLocalizations.of(context)!.dialogContent,
      onDisablePressed: () {
        Navigator.of(context).pop();
      },
      onEnablePressed: () {
        handleAcceptOnShowDialogEditTask();
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      },
      acceptButtonLabel: AppLocalizations.of(context)!.dialogAcceptButton,
      cancelbuttonLabel: AppLocalizations.of(context)!.dialogCancelButton,
    );
  }

  void handleCancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final taskListViewModel =
        Provider.of<TaskListViewModel>(context, listen: false);

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 36.0),
              Text(
                widget.detail
                    ? AppLocalizations.of(context)!.createTaskPage_titleOnEdit
                    : AppLocalizations.of(context)!.createTaskPage_title,
                style: TextStyle(fontSize: 32.0),
              ),
              const SizedBox(height: 20.0),
              if (!widget.detail)
                Column(
                  children: [
                    ToggleButtons(
                      isSelected: [selectedIndex == 0, selectedIndex == 1],
                      onPressed: (int index) {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      children: [
                        Text(AppLocalizations.of(context)!
                            .createTaskPage_scheduled),
                        Text(AppLocalizations.of(context)!
                            .createTaskPage_inspection),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                  ],
                ),
              const SizedBox(height: 20.0),
              if (selectedIndex == 1)
                Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)!
                          .createTaskPage_numberWorkTitle,
                      style: TextStyle(fontSize: 24.0),
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!
                            .default_placeHolderInputText,
                        border: OutlineInputBorder(),
                      ),
                      controller: numWorkController,
                    ),
                    const SizedBox(height: 10.0),
                    if (widget.detail)
                      const Text(
                        'Estado',
                        style: TextStyle(fontSize: 24.0),
                      ),
                    DropdownButton<String>(
                      value: taskStatus,
                      onChanged: (String? value) {
                        setState(() {
                          taskStatus = value!;
                        });
                      },
                      items: TaskStatus.values.map((TaskStatus status) {
                        return DropdownMenuItem<String>(
                          value: status.value,
                          child: Text(status.value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      AppLocalizations.of(context)!
                          .createTaskPage_startDateTitle,
                      style: TextStyle(fontSize: 24.0),
                    ),
                    InkWell(
                      onTap: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: startDate!,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          handleStartDateChange(pickedDate);
                        }
                      },
                      child: IgnorePointer(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Select Date and Time',
                          ),
                          //initialValue:  DateFormat('dd-MM-yyyy').format(startDate),
                          controller: addDateController,
                          enabled: false,
                          readOnly: true,
                        ),
                      ),
                    ),
                    if (widget.detail) const SizedBox(height: 10.0),
                    if (widget.detail)
                      const Text(
                        'Fecha de Realización',
                        style: TextStyle(fontSize: 24.0),
                      ),
                    if (widget.detail)
                      InkWell(
                        onTap: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: releasedDate!,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            handleReleasedDateChange(pickedDate);
                          }
                        },
                        child: IgnorePointer(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              hintText: 'Select Date and Time',
                            ),
                            //initialValue:  DateFormat('dd-MM-yyyy').format(startDate),
                            controller: releasedDateController,
                            enabled: false,
                            readOnly: true,
                          ),
                        ),
                      ),
                    const SizedBox(height: 10.0),
                    Text(
                      AppLocalizations.of(context)!
                          .createTaskPage_selectUbicationTitle,
                      style: TextStyle(fontSize: 24.0),
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!
                            .default_placeHolderInputText,
                        border: OutlineInputBorder(),
                      ),
                      controller: locationController,
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      AppLocalizations.of(context)!
                          .createTaskPage_assignedUserTitle,
                      style: TextStyle(fontSize: 24.0),
                    ),
                    if (!widget.detail)
                      DropdownButton<String>(
                        value: userAssigned,
                        onChanged: (String? value) {
                          setState(() {
                            userAssigned = value!;
                          });
                        },
                        items: const [
                          DropdownMenuItem<String>(
                            value: 'not-assigned',
                            child: Text('Elija una opción'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'gtau-oper',
                            child: Text('gtau-oper'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'gtau-admin',
                            child: Text('gtau-oper'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'operario3',
                            child: Text('Operario C'),
                          ),
                        ],
                      ),
                    const SizedBox(height: 10.0),
                    if (widget.detail)
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!
                              .default_placeHolderInputText,
                          border: const OutlineInputBorder(),
                        ),
                        controller: userAssignedController,
                      ),
                    const SizedBox(height: 10.0),
                    Text(
                      AppLocalizations.of(context)!
                          .createTaskPage_solicitantTitle,
                      style: const TextStyle(fontSize: 24.0),
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!
                            .default_placeHolderInputText,
                        border: const OutlineInputBorder(),
                      ),
                      controller: applicantController,
                    ),
                    const SizedBox(height: 10.0)
                  ],
                ),
              if (selectedIndex == 0)
                Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.createTaskPage_scheduled,
                      style: const TextStyle(fontSize: 24.0),
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!
                            .default_placeHolderInputText,
                        border: const OutlineInputBorder(),
                      ),
                      controller: scheduledNumberController,
                    ),
                  ],
                ),
              const SizedBox(height: 10.0),
              Text(
                AppLocalizations.of(context)!.default_descriptionTitle,
                style: const TextStyle(fontSize: 24.0),
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!
                      .default_descriptionPlaceholder,
                  border: const OutlineInputBorder(),
                ),
                controller: descriptionController,
              ),
              if (widget.detail)
                Column(
                  children: [
                    const SizedBox(height: 10.0),
                    const Text(
                      'Longitud',
                      style: TextStyle(fontSize: 24.0),
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!
                            .default_descriptionPlaceholder,
                        border: const OutlineInputBorder(),
                      ),
                      controller: lengthController,
                    ),
                    const SizedBox(height: 10.0),
                    const Text(
                      'Material',
                      style: TextStyle(fontSize: 24.0),
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!
                            .default_descriptionPlaceholder,
                        border: const OutlineInputBorder(),
                      ),
                      controller: materialController,
                    ),
                    const SizedBox(height: 10.0),
                    const Text(
                      'Observaciones',
                      style: TextStyle(fontSize: 24.0),
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!
                            .default_descriptionPlaceholder,
                        border: const OutlineInputBorder(),
                      ),
                      controller: observationsController,
                    ),
                    const SizedBox(height: 10.0),
                    const Text(
                      'Conclusiones',
                      style: TextStyle(fontSize: 24.0),
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!
                            .default_descriptionPlaceholder,
                        border: const OutlineInputBorder(),
                      ),
                      controller: conclusionsController,
                    ),
                  ],
                ),
              Container(
                height: 50.0,
                margin: const EdgeInsets.symmetric(vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.detail)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: handleCancel,
                        child: Text(
                            AppLocalizations.of(context)!.buttonCancelLabel),
                      ),
                    const SizedBox(width: 10.0),
                    ElevatedButton(
                      onPressed: widget.detail ? handleEditTask : handleSubmit,
                      child: widget.detail
                          ? Text(
                              AppLocalizations.of(context)!.buttonAcceptLabel)
                          : Text(AppLocalizations.of(context)!
                              .createTaskPage_submitButton),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
