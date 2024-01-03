import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtau_app_front/models/scheduled/task_scheduled.dart';
import 'package:gtau_app_front/viewmodels/task_list_scheduled_viewmodel.dart';
import 'package:gtau_app_front/widgets/common/box_container.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import '../../../constants/app_constants.dart';
import '../../../constants/theme_constants.dart';
import '../../../models/scheduled/zone.dart';
import '../../../models/task_status.dart';
import '../../../providers/user_provider.dart';
import '../../../utils/date_utils.dart';
import '../../../viewmodels/scheduled_viewmodel.dart';
import '../../../viewmodels/zone_load_viewmodel.dart';
import '../../scheduled_map_component.dart';
import '../customDialog.dart';
import '../customMessageDialog.dart';
import '../custom_dropdown.dart';
import '../custom_elevated_button.dart';
import '../custom_text_form_field.dart';
import '../file_upload_component.dart';

class ScheduledComponent extends StatefulWidget {
  final bool isEdit;
  final int? scheduledId;

  const ScheduledComponent(
      {Key? key, this.isEdit = false, required this.scheduledId})
      : super(key: key);

  @override
  State<ScheduledComponent> createState() => _CreateScheduledState();
}

class _CreateScheduledState extends State<ScheduledComponent> {
  final titleController = TextEditingController();
  final addDateController = TextEditingController();
  final releasedDateController = TextEditingController();
  final numWorkController = TextEditingController();
  final descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> geojsonFromFile = {};
  late String taskStatus = 'PENDING';
  late DateTime? startDate;
  late DateTime? releasedDate;
  late bool isAdmin;
  late TaskListScheduledViewModel taskListScheduledViewModel;
  late ScheduledViewModel scheduledViewModel;
  late ZoneLoadViewModel zoneLoadViewModel;
  late String token;
  late bool isZoneLoaded = false;
  late bool creatingScheduled = false;
  late TaskScheduled? taskScheduledResponse = null;
  late bool? zoneCreated = null;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await initializeScheduledTask();
      });
    } else {
      startDate = DateTime.now();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isAdmin = context.read<UserProvider>().isAdmin!;
    taskListScheduledViewModel =
        Provider.of<TaskListScheduledViewModel>(context, listen: false);
    token = Provider.of<UserProvider>(context, listen: false).getToken!;
    scheduledViewModel =
        Provider.of<ScheduledViewModel>(context, listen: false);
  }

  @override
  void dispose() {
    titleController.dispose();
    addDateController.dispose();
    numWorkController.dispose();
    releasedDateController.dispose();
    descriptionController.dispose();
    scheduledViewModel.reset();
    super.dispose();
  }

  Future<void> initializeScheduledTask() async {
    TaskScheduled? taskScheduled = await taskListScheduledViewModel
        .fetchTaskScheduled(token, widget.scheduledId!)
        .catchError((error) async {
      // Manejo de error
      await showCustomMessageDialog(
        context: context,
        onAcceptPressed: () {
          Navigator.of(context).pop();
        },
        customText: AppLocalizations.of(context)!.error_generic_text,
        messageType: DialogMessageType.error,
      );
      return null;
    });
    loadInfoFromTaskScheduledResponse(taskScheduled);

    ScheduledZone? scheduledZone = await scheduledViewModel
        .fetchZoneFromScheduled(token, widget.scheduledId!);

    setState(() {
      isZoneLoaded = scheduledZone != null;
    });
  }

  void loadInfoFromTaskScheduledResponse(TaskScheduled? taskScheduled) {
    if (taskScheduled != null) {
      titleController.text = taskScheduled.title ?? '';
      startDate = taskScheduled.addDate!;
      taskStatus = taskScheduled.status!;
      descriptionController.text = taskScheduled.description!;
      if (taskScheduled.releasedDate != null) {
        releasedDate = taskScheduled.releasedDate!;
        releasedDateController.text =
            parseDateTimeOnFormat(taskScheduled.releasedDate!);
      }
      addDateController.text = parseDateTimeOnFormat(taskScheduled.addDate!);
    }
  }

  void _handleStartDateChange(DateTime date) {
    setState(() {
      startDate = date;
    });
    addDateController.text = parseDateTimeOnFormat(date);
  }

  void _handleReleasedDateChange(DateTime date) {
    setState(() {
      releasedDate = date;
    });
    releasedDateController.text = parseDateTimeOnFormat(date);
  }

  void _showMapElement(BuildContext context) {
    double widthWindow = MediaQuery.of(context).size.width;

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ScheduledMapComponent(idSheduled: widget.scheduledId)),
    );
  }

  Map<String, dynamic> bodyScheduledTask() {
    late String addDateUpdated = formattedDateToUpdate(addDateController.text);

    late String? releasedDateUpdated = releasedDateController.text.isNotEmpty
        ? formattedDateToUpdate(releasedDateController.text)
        : null;

    return {
      "title": titleController.text,
      "status": taskStatus,
      "description": descriptionController.text,
      "releasedDate": releasedDateUpdated,
      "addDate": addDateUpdated,
    };
  }

  void _showConfirmationDialog(
      {Function? cancelPressed, Function? acceptPressed}) async {
    await showCustomDialog(
      context: context,
      title: AppLocalizations.of(context)!.dialogWarning,
      content: AppLocalizations.of(context)!.dialogContent,
      onDisablePressed: () {
        if (cancelPressed != null) {
          cancelPressed();
        }
      },
      onEnablePressed: () {
        if (acceptPressed != null) {
          acceptPressed();
        }
      },
      acceptButtonLabel: AppLocalizations.of(context)!.dialogAcceptButton,
      cancelbuttonLabel: AppLocalizations.of(context)!.dialogCancelButton,
    );
  }

  Future<TaskScheduled?> handleAcceptOnShowDialogCreateTask() async {
    Map<String, dynamic> body = bodyScheduledTask();

    return await taskListScheduledViewModel.createScheduledTask(token, body);
  }

  void handleSubmit() {
    _showConfirmationDialog(cancelPressed: () {
      Navigator.of(context).pop();
    }, acceptPressed: () async {
      Navigator.of(context).pop();
      setState(() {
        creatingScheduled = true;
      });
      TaskScheduled? taskCreated = await handleAcceptOnShowDialogCreateTask();
      setState(() {
        taskScheduledResponse = taskCreated;
      });

      if (taskScheduledResponse != null) {
        bool created = await scheduledViewModel.createScheduledZone(
            token, taskScheduledResponse!.id!, geojsonFromFile);
        setState(() {
          zoneCreated = created;
        });
        await manageLoadZoneProcess(taskScheduledResponse!);
      }

      // if (taskScheduledResponse != null &&
      //     zoneCreated != null &&
      //     zoneCreated!) {
      //   await showMessageDialog(DialogMessageType.success);
      //   return true;
      // } else {
      //   await showMessageDialog(DialogMessageType.error);
      //   return false;
      // }
    });
  }

  Future<void> manageLoadZoneProcess(
      TaskScheduled taskScheduledResponse) async {
    zoneLoadViewModel = Provider.of<ZoneLoadViewModel>(context, listen: false);
    await zoneLoadViewModel.waitForWebSocketConnection();
    zoneLoadViewModel.sendMessage(
        token: token,
        operation: 'start',
        type: 'SCHEDULED_CHARGE',
        id: taskScheduledResponse.id!);
  }

  Future<bool> handleAcceptOnShowDialogEditTask() async {
    Map<String, dynamic> body = bodyScheduledTask();
    bool isUpdated = await taskListScheduledViewModel.updateTaskScheduled(
        token, widget.scheduledId!, body);
    if (isUpdated) {
      await showMessageDialog(DialogMessageType.success);
      return true;
    } else {
      await showMessageDialog(DialogMessageType.error);
      return false;
    }
  }

  void handleEdit() {
    _showConfirmationDialog(cancelPressed: () {
      Navigator.of(context).pop();
    }, acceptPressed: () async {
      Navigator.of(context).pop();
      await handleAcceptOnShowDialogEditTask();
      Navigator.of(context).pop();
    });
  }

  Future<void> showMessageDialog(DialogMessageType type) async {
    await showCustomMessageDialog(
        context: context, messageType: type, onAcceptPressed: () {});
  }

  @override
  Widget build(BuildContext context) {
    double widthRow = 640;
    double heightRow = 128;

    return Column(children: [
      Visibility(
        visible: widget.isEdit,
        child: Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 0, 0),
            child: FloatingActionButton(
              foregroundColor: primarySwatch,
              backgroundColor: lightBackground,
              onPressed: () {
                scheduledViewModel.reset();
                Navigator.of(context).pop();
              },
              tooltip: AppLocalizations.of(context)!.placeholder_back_button,
              child: const Icon(Icons.arrow_back),
            ),
          ),
        ),
      ),
      Center(
          child: Column(children: [
        BoxContainer(
          width: widthRow * 1.15,
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.scheduled_main_title,
                  style: const TextStyle(fontSize: 32.0),
                ),
                Column(
                  children: [
                    const SizedBox(height: 24.0),
                    Text(
                      AppLocalizations.of(context)!.scheduled_title_input,
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    const SizedBox(height: 12.0),
                    CustomTextFormField(
                      width: widthRow,
                      hintText: AppLocalizations.of(context)!
                          .default_placeHolderInputText,
                      controller: titleController,
                    ),
                    SizedBox(
                      width: widthRow,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              const SizedBox(
                                  height: AppConstants.taskColumnSpace),
                              Text(
                                AppLocalizations.of(context)!
                                    .createTaskPage_startDateTitle,
                                style: const TextStyle(fontSize: 16.0),
                              ),
                              const SizedBox(height: 12.0),
                              SizedBox(
                                width: AppConstants.textFieldWidth,
                                child: InkWell(
                                  overlayColor: MaterialStateColor.resolveWith(
                                      (states) => Colors.transparent),
                                  onTap: () async {
                                    final DateTime? pickedDate =
                                        await showCustomDatePicker(
                                            context, startDate!);
                                    if (pickedDate != null) {
                                      _handleStartDateChange(pickedDate);
                                    }
                                  },
                                  child: IgnorePointer(
                                    child: CustomTextFormField(
                                      width: AppConstants.taskRowSpace,
                                      hintText: AppLocalizations.of(context)!
                                          .createTaskPage_startDateTitle,
                                      controller: addDateController,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Column(
                            children: [
                              const SizedBox(
                                  height: AppConstants.taskColumnSpace),
                              Text(
                                AppLocalizations.of(context)!
                                    .scheduled_end_date_title,
                                style: const TextStyle(fontSize: 16.0),
                              ),
                              const SizedBox(height: 12.0),
                              SizedBox(
                                width: AppConstants.textFieldWidth,
                                child: InkWell(
                                  overlayColor: MaterialStateColor.resolveWith(
                                      (states) => Colors.transparent),
                                  onTap: () async {
                                    final DateTime? pickedDate =
                                        await showCustomDatePicker(
                                            context, startDate!);
                                    if (pickedDate != null) {
                                      _handleReleasedDateChange(pickedDate);
                                    }
                                  },
                                  child: IgnorePointer(
                                    child: CustomTextFormField(
                                      useValidation: false,
                                      width: AppConstants.taskRowSpace,
                                      hintText: AppLocalizations.of(context)!
                                          .scheduled_end_date_title,
                                      controller: releasedDateController,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.taskRowSpace),
                          Column(
                            children: [
                              Text(
                                AppLocalizations.of(context)!
                                    .editTaskPage_statusTitle,
                                style: const TextStyle(fontSize: 16.0),
                              ),
                              const SizedBox(
                                  height: AppConstants.taskColumnSpace),
                              CustomDropdown(
                                isStatus: true,
                                value: taskStatus,
                                onChanged: (String? value) {
                                  setState(() {
                                    taskStatus = value!;
                                  });
                                },
                                items: TaskStatus.values
                                    .map((status) => status.value)
                                    .toList(),
                              ),
                              const SizedBox(height: 28),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.default_descriptionTitle,
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    const SizedBox(height: 10.0),
                    CustomTextFormField(
                      useValidation: false,
                      isTextBox: true,
                      maxLines: 10,
                      width: widthRow,
                      hintText: AppLocalizations.of(context)!
                          .default_descriptionPlaceholder,
                      controller: descriptionController,
                    ),
                    const SizedBox(height: 24.0),
                    Visibility(
                      visible: isAdmin && !isZoneLoaded && !creatingScheduled,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.scheduled_file_title,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: widthRow,
                            child: FileUploadComponent(
                              onFileAdded: (Map<String, dynamic> fileContent) {
                                setState(() {
                                  geojsonFromFile = fileContent;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ],
                ),
                Visibility(
                  visible: widget.isEdit && isZoneLoaded,
                  child: Column(children: [
                    Text(
                      AppLocalizations.of(context)!.inspect_map_title,
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    const SizedBox(height: 12),
                    CustomElevatedButton(
                      onPressed: () async {
                        _showMapElement(context);
                      },
                      text: AppLocalizations.of(context)!.see_map_button,
                    )
                  ]),
                ),
                Visibility(
                  visible: creatingScheduled,
                  child: SizedBox(
                    height: 150,
                    child: Center(child: Consumer<ScheduledViewModel>(
                      builder: (context, scheduledViewModel, child) {
                        return Consumer<TaskListScheduledViewModel>(
                          builder:
                              (context, taskListScheduledViewModel, child) {
                            return Consumer<ZoneLoadViewModel>(
                              builder: (context, zoneLoadViewModel, child) {
                                return Visibility(
                                  visible: true,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                        children: [
                                          zoneLoadViewModel.warning
                                              ? Text(zoneLoadViewModel.message!)
                                              : const Text(
                                                  'Se esta procesando. Este proceso puede demorar unos minutos.'),
                                          const SizedBox(height: 4),
                                          Visibility(
                                            visible:
                                                zoneLoadViewModel.isLoading ||
                                                    zoneLoadViewModel
                                                            .connectionStatus ==
                                                        SocketConnectionStatus
                                                            .connecting,
                                            child: const Center(
                                              child: CircularProgressIndicator(
                                                color: Color.fromRGBO(
                                                    96, 166, 27, 1),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Text(
                                              'Creación de Programada: '),
                                          Visibility(
                                            visible: taskListScheduledViewModel
                                                .isLoading,
                                            child:
                                                LoadingAnimationWidget.waveDots(
                                              color: primarySwatch[400]!,
                                              size: 20,
                                            ),
                                          ),
                                          Visibility(
                                              visible:
                                                  !taskListScheduledViewModel
                                                      .isLoading,
                                              child: taskScheduledResponse !=
                                                      null
                                                  ? Icon(Icons.check_circle,
                                                      color:
                                                          primarySwatch[400]!,
                                                      size: 20)
                                                  : const Icon(Icons.error,
                                                      color: Colors.red,
                                                      size: 20)),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Text('Creando Zonas: '),
                                          Visibility(
                                            visible:
                                                scheduledViewModel.isLoading,
                                            child:
                                                LoadingAnimationWidget.waveDots(
                                              color: primarySwatch[400]!,
                                              size: 20,
                                            ),
                                          ),
                                          Visibility(
                                              visible:
                                                  !scheduledViewModel.isLoading,
                                              child: zoneCreated != null &&
                                                      zoneCreated!
                                                  ? Icon(Icons.check_circle,
                                                      color:
                                                          primarySwatch[400]!,
                                                      size: 20)
                                                  : const Icon(Icons.error,
                                                      color: Colors.red,
                                                      size: 20)),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Text('Tramos: '),
                                          Visibility(
                                            visible: zoneLoadViewModel
                                                .isLoadingSections,
                                            child:
                                                LoadingAnimationWidget.waveDots(
                                              color: primarySwatch[400]!,
                                              size: 20,
                                            ),
                                          ),
                                          Visibility(
                                              visible: !zoneLoadViewModel
                                                      .isLoadingSections &&
                                                  zoneLoadViewModel
                                                          .connectionStatus ==
                                                      SocketConnectionStatus
                                                          .connected,
                                              child: zoneLoadViewModel
                                                      .sectionsResult
                                                  ? Icon(Icons.check_circle,
                                                      color:
                                                          primarySwatch[400]!,
                                                      size: 20)
                                                  : const Icon(Icons.error,
                                                      color: Colors.red,
                                                      size: 20)),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Text('Captacion: '),
                                          Visibility(
                                            visible: zoneLoadViewModel
                                                    .isLoadingCatchments &&
                                                zoneLoadViewModel
                                                        .connectionStatus ==
                                                    SocketConnectionStatus
                                                        .connected,
                                            child:
                                                LoadingAnimationWidget.waveDots(
                                              color: primarySwatch[400]!,
                                              size: 20,
                                            ),
                                          ),
                                          Visibility(
                                              visible: !zoneLoadViewModel
                                                  .isLoadingCatchments,
                                              child: zoneLoadViewModel
                                                      .catchmentsResult
                                                  ? Icon(Icons.check_circle,
                                                      color:
                                                          primarySwatch[400]!,
                                                      size: 20)
                                                  : const Icon(Icons.error,
                                                      color: Colors.red,
                                                      size: 20)),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Text('Registros: '),
                                          Visibility(
                                            visible: zoneLoadViewModel
                                                .isLoadingRegisters,
                                            child:
                                                LoadingAnimationWidget.waveDots(
                                              color: primarySwatch[400]!,
                                              size: 20,
                                            ),
                                          ),
                                          Visibility(
                                              visible: !zoneLoadViewModel
                                                      .isLoadingRegisters &&
                                                  zoneLoadViewModel
                                                          .connectionStatus ==
                                                      SocketConnectionStatus
                                                          .connected,
                                              child: zoneLoadViewModel
                                                      .registersResult
                                                  ? Icon(Icons.check_circle,
                                                      color:
                                                          primarySwatch[400]!,
                                                      size: 20)
                                                  : const Icon(Icons.error,
                                                      color: Colors.red,
                                                      size: 20)),
                                        ],
                                      ),
                                      if (zoneLoadViewModel.error)
                                        Text(
                                            'Error: ${zoneLoadViewModel.message}'),
                                      if (zoneLoadViewModel.result != null)
                                        Text(
                                            'Result: ${zoneLoadViewModel.result! ? "Success" : "Error"}'),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    )),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppConstants.taskColumnSpace),
        CustomElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              widget.isEdit ? handleEdit() : handleSubmit();
            }
          },
          text: widget.isEdit
              ? AppLocalizations.of(context)!.buttonAcceptLabel
              : AppLocalizations.of(context)!.createTaskPage_submitButton,
        ),
      ]))
    ]);
  }
}
