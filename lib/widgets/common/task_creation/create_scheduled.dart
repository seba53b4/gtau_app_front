import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtau_app_front/models/scheduled/task_scheduled.dart';
import 'package:gtau_app_front/providers/task_filters_provider.dart';
import 'package:gtau_app_front/viewmodels/task_list_scheduled_viewmodel.dart';
import 'package:gtau_app_front/widgets/common/box_container.dart';
import 'package:gtau_app_front/widgets/common/reports_components.dart';
import 'package:gtau_app_front/widgets/loading_overlay.dart';
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
import '../info_icon.dart';

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
  late ZoneLoadViewModel? zoneLoadViewModel;
  late String token;
  late bool isZoneLoaded = false;
  late bool creatingScheduled = false;
  late TaskScheduled? taskScheduledResponse = null;
  late bool? zoneCreated = null;
  bool errorFileUpload = false;
  double heightToAddOnCreate = 80;
  late ScheduledZone? scheduledZone;
  late bool creatingScheduledError = false;

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
    zoneLoadViewModel = null;
  }

  @override
  void dispose() {
    titleController.dispose();
    addDateController.dispose();
    numWorkController.dispose();
    releasedDateController.dispose();
    descriptionController.dispose();
    scheduledViewModel.reset();
    zoneLoadViewModel?.reset();
    super.dispose();
  }

  Future<void> initializeScheduledTask() async {
    TaskScheduled? taskScheduled = await taskListScheduledViewModel
        .fetchTaskScheduled(token, widget.scheduledId!)
        .catchError((error) async {
      // Manejo de error
      showGenericModalError();
      return null;
    });
    loadInfoFromTaskScheduledResponse(taskScheduled);

    ScheduledZone? scheduledZoneResp = await scheduledViewModel
        .fetchZoneFromScheduled(token, widget.scheduledId!);

    isZoneLoaded = scheduledZoneResp != null;
    if (scheduledZoneResp != null) {
      scheduledZone = scheduledZoneResp;
    }
  }

  Future updateTaskList() async {
    final scheduledListViewModel =
        Provider.of<TaskListScheduledViewModel>(context, listen: false);
    final token = Provider.of<UserProvider>(context, listen: false).getToken;
    final status =
        Provider.of<TaskFilterProvider>(context, listen: false).lastStatus;
    scheduledListViewModel.clearListByStatus(status!);
    await scheduledListViewModel.fetchScheduledTasks(token!, status);
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
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ScheduledMapComponent(
              idSheduled: widget.scheduledId, scheduledZone: scheduledZone)),
    );
  }

  Map<String, dynamic> bodyScheduledTask() {
    late String addDateUpdated = formattedDate(addDateController.text);

    late String? releasedDateUpdated = releasedDateController.text.isNotEmpty
        ? formattedDate(releasedDateController.text)
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

  void initProcess() {
    setState(() {
      creatingScheduledError = false;
    });
    startCreationProcess();
    if (!creatingScheduledError) {
      updateTaskList();
    }
  }

  void handleSubmit() {
    if (geojsonFromFile.isNotEmpty) {
      _showConfirmationDialog(cancelPressed: () {
        Navigator.of(context).pop();
      }, acceptPressed: () {
        initProcess();
        Navigator.of(context).pop();
      });
    } else {
      setState(() {
        errorFileUpload = true;
      });
    }
  }

  void startCreationProcess() async {
    if (geojsonFromFile.isNotEmpty) {
      TaskScheduled? taskCreated = await handleAcceptOnShowDialogCreateTask();

      setState(() {
        taskScheduledResponse = taskCreated;
      });

      if (taskScheduledResponse != null) {
        setState(() {
          creatingScheduled = true;
        });
        bool created = await scheduledViewModel.createScheduledZone(
            token, taskScheduledResponse!.id!, geojsonFromFile);
        setState(() {
          zoneCreated = created;
        });
        await manageLoadZoneProcess(taskScheduledResponse!);
      } else {
        setState(() {
          creatingScheduledError = true;
        });
      }
    }
  }

  void showGenericModalError({Function? onAcceptPressed}) async {
    await showCustomMessageDialog(
      context: context,
      onAcceptPressed: () {
        if (onAcceptPressed != null) {
          onAcceptPressed();
        }
      },
      customText: AppLocalizations.of(context)!.error_generic_text,
      messageType: DialogMessageType.error,
    );
  }

  Future<void> manageLoadZoneProcess(
      TaskScheduled taskScheduledResponse) async {
    setState(() {
      zoneLoadViewModel =
          Provider.of<ZoneLoadViewModel>(context, listen: false);
    });
    zoneLoadViewModel!.initWS();
    await zoneLoadViewModel!.waitForWebSocketConnection();
    initializeProcess();
  }

  void initializeProcess() {
    zoneLoadViewModel!.initializeProcess(
        token: token,
        operation: 'start',
        type: 'SCHEDULED_CHARGE',
        id: taskScheduledResponse!.id!);
  }

  Future<bool> handleAcceptOnShowDialogEditTask() async {
    Map<String, dynamic> body = bodyScheduledTask();
    bool isUpdated = await taskListScheduledViewModel.updateTaskScheduled(
        token, widget.scheduledId!, body);
    if (isUpdated) {
      await showMessageDialog(DialogMessageType.success);
      await updateTaskList();
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
    double fontCreateTask = 16.0;
    final appLocalizations = AppLocalizations.of(context)!;

    return Consumer<ScheduledViewModel>(
        builder: (context, scheduledViewModel, child) {
      return Consumer<TaskListScheduledViewModel>(
          builder: (context, taskListScheduledViewModel, child) {
        return Consumer<ZoneLoadViewModel>(
            builder: (context, zoneLoadViewModel, child) {
          return LoadingOverlay(
              isLoading: scheduledViewModel.isLoading ||
                  taskListScheduledViewModel.isLoading ||
                  scheduledViewModel.isLoadingZone,
              child: Column(children: [
                Visibility(
                  visible: widget.isEdit && kIsWeb,
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
                        tooltip: appLocalizations.placeholder_back_button,
                        child: const Icon(Icons.arrow_back),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    children: [
                      BoxContainer(
                        height: creatingScheduledError
                            ? 890
                            : creatingScheduled
                                ? 730 + heightToAddOnCreate
                                : widget.isEdit
                                    ? kIsWeb
                                        ? 798
                                        : 835
                                    : 706,
                        width: widthRow * 1.15,
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Text(
                                appLocalizations.scheduled_main_title,
                                style: const TextStyle(
                                    fontSize: kIsWeb ? 32.0 : 22),
                              ),
                              Column(
                                children: [
                                  const SizedBox(height: 24.0),
                                  Text(
                                    appLocalizations.scheduled_title_input,
                                    style: const TextStyle(fontSize: 16.0),
                                  ),
                                  const SizedBox(height: 12.0),
                                  CustomTextFormField(
                                    width: widthRow,
                                    hintText: appLocalizations
                                        .default_placeHolderInputText,
                                    controller: titleController,
                                  ),
                                  SizedBox(
                                    width: widthRow,
                                    child: kIsWeb
                                        ? Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                children: [
                                                  const SizedBox(
                                                      height: AppConstants
                                                          .taskColumnSpace),
                                                  Text(
                                                    appLocalizations
                                                        .createTaskPage_startDateTitle,
                                                    style: const TextStyle(
                                                        fontSize: 16.0),
                                                  ),
                                                  const SizedBox(height: 12.0),
                                                  SizedBox(
                                                    width: AppConstants
                                                        .textFieldWidth,
                                                    child: InkWell(
                                                      overlayColor: MaterialStateColor
                                                          .resolveWith(
                                                              (states) => Colors
                                                                  .transparent),
                                                      onTap: () async {
                                                        final DateTime?
                                                            pickedDate =
                                                            await showCustomDatePicker(
                                                                context,
                                                                startDate!);
                                                        if (pickedDate !=
                                                            null) {
                                                          _handleStartDateChange(
                                                              pickedDate);
                                                        }
                                                      },
                                                      child: IgnorePointer(
                                                        child:
                                                            CustomTextFormField(
                                                          width: AppConstants
                                                              .taskRowSpace,
                                                          hintText: appLocalizations
                                                              .createTaskPage_startDateTitle,
                                                          controller:
                                                              addDateController,
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
                                                      height: AppConstants
                                                          .taskColumnSpace),
                                                  Text(
                                                    appLocalizations
                                                        .scheduled_end_date_title,
                                                    style: const TextStyle(
                                                        fontSize: 16.0),
                                                  ),
                                                  const SizedBox(height: 12.0),
                                                  SizedBox(
                                                    width: AppConstants
                                                        .textFieldWidth,
                                                    child: InkWell(
                                                      overlayColor: MaterialStateColor
                                                          .resolveWith(
                                                              (states) => Colors
                                                                  .transparent),
                                                      onTap: () async {
                                                        final DateTime?
                                                            pickedDate =
                                                            await showCustomDatePicker(
                                                                context,
                                                                startDate!);
                                                        if (pickedDate !=
                                                            null) {
                                                          _handleReleasedDateChange(
                                                              pickedDate);
                                                        }
                                                      },
                                                      child: IgnorePointer(
                                                        child:
                                                            CustomTextFormField(
                                                          useValidation: false,
                                                          width: AppConstants
                                                              .taskRowSpace,
                                                          hintText: appLocalizations
                                                              .scheduled_end_date_title,
                                                          controller:
                                                              releasedDateController,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                  height: AppConstants
                                                      .taskRowSpace),
                                              Column(
                                                children: [
                                                  Text(
                                                    appLocalizations
                                                        .editTaskPage_statusTitle,
                                                    style: const TextStyle(
                                                        fontSize: 16.0),
                                                  ),
                                                  const SizedBox(
                                                      height: AppConstants
                                                          .taskColumnSpace),
                                                  CustomDropdown(
                                                    isStatus: true,
                                                    value: taskStatus,
                                                    onChanged: (String? value) {
                                                      setState(() {
                                                        taskStatus = value!;
                                                      });
                                                    },
                                                    items: TaskStatus.values
                                                        .map((status) =>
                                                            status.value)
                                                        .toList(),
                                                  ),
                                                  const SizedBox(height: 28),
                                                ],
                                              ),
                                            ],
                                          )
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                children: [
                                                  Text(
                                                    appLocalizations
                                                        .createTaskPage_startDateTitle,
                                                    style: const TextStyle(
                                                        fontSize: 16.0),
                                                  ),
                                                  const SizedBox(height: 12.0),
                                                  SizedBox(
                                                    width: AppConstants
                                                        .textFieldWidth,
                                                    child: InkWell(
                                                      overlayColor: MaterialStateColor
                                                          .resolveWith(
                                                              (states) => Colors
                                                                  .transparent),
                                                      onTap: () async {
                                                        final DateTime?
                                                            pickedDate =
                                                            await showCustomDatePicker(
                                                                context,
                                                                startDate!);
                                                        if (pickedDate !=
                                                            null) {
                                                          _handleStartDateChange(
                                                              pickedDate);
                                                        }
                                                      },
                                                      child: IgnorePointer(
                                                        child:
                                                            CustomTextFormField(
                                                          width: AppConstants
                                                              .taskRowSpace,
                                                          fontSize: 14,
                                                          hintText: appLocalizations
                                                              .createTaskPage_startDateTitle,
                                                          controller:
                                                              addDateController,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              // const SizedBox(height: 8),
                                              Column(
                                                children: [
                                                  const SizedBox(
                                                      height: AppConstants
                                                          .taskColumnSpace),
                                                  Text(
                                                    appLocalizations
                                                        .scheduled_end_date_title,
                                                    style: const TextStyle(
                                                        fontSize: 16.0),
                                                  ),
                                                  const SizedBox(height: 12.0),
                                                  SizedBox(
                                                    width: AppConstants
                                                        .textFieldWidth,
                                                    child: InkWell(
                                                      overlayColor: MaterialStateColor
                                                          .resolveWith(
                                                              (states) => Colors
                                                                  .transparent),
                                                      onTap: () async {
                                                        final DateTime?
                                                            pickedDate =
                                                            await showCustomDatePicker(
                                                                context,
                                                                startDate!);
                                                        if (pickedDate !=
                                                            null) {
                                                          _handleReleasedDateChange(
                                                              pickedDate);
                                                        }
                                                      },
                                                      child: IgnorePointer(
                                                        child:
                                                            CustomTextFormField(
                                                          useValidation: false,
                                                          fontSize: 14,
                                                          width: AppConstants
                                                              .taskRowSpace,
                                                          hintText: appLocalizations
                                                              .scheduled_end_date_title,
                                                          controller:
                                                              releasedDateController,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              // const SizedBox(
                                              //     height: AppConstants.taskRowSpace),
                                              Column(
                                                children: [
                                                  Text(
                                                    appLocalizations
                                                        .editTaskPage_statusTitle,
                                                    style: const TextStyle(
                                                        fontSize: 18.0),
                                                  ),
                                                  const SizedBox(
                                                      height: AppConstants
                                                          .taskColumnSpace),
                                                  CustomDropdown(
                                                    isStatus: true,
                                                    value: taskStatus,
                                                    fontSize: 14,
                                                    onChanged: (String? value) {
                                                      setState(() {
                                                        taskStatus = value!;
                                                      });
                                                    },
                                                    items: TaskStatus.values
                                                        .map((status) =>
                                                            status.value)
                                                        .toList(),
                                                  ),
                                                  const SizedBox(height: 26),
                                                ],
                                              ),
                                            ],
                                          ),
                                  ),
                                  Text(
                                    appLocalizations.default_descriptionTitle,
                                    style: const TextStyle(fontSize: 16.0),
                                  ),
                                  const SizedBox(height: 10.0),
                                  CustomTextFormField(
                                    useValidation: false,
                                    isTextBox: true,
                                    maxLines: 10,
                                    width: widthRow,
                                    hintText: appLocalizations
                                        .default_descriptionPlaceholder,
                                    controller: descriptionController,
                                  ),
                                  const SizedBox(height: 24.0),
                                  Visibility(
                                    visible: isAdmin &&
                                        !isZoneLoaded &&
                                        !creatingScheduled &&
                                        !widget.isEdit,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              appLocalizations
                                                  .scheduled_file_title,
                                              style: const TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                            InfoIcon(
                                                message: appLocalizations
                                                    .info_icon_msg_file_upload),
                                          ],
                                        ),
                                        SizedBox(
                                            height: errorFileUpload ? 4 : 12),
                                        SizedBox(
                                          width: widthRow * 0.6,
                                          child: FileUploadComponent(
                                            errorVisible: errorFileUpload,
                                            errorMessage: appLocalizations
                                                .info_icon_msg_file_upload_error,
                                            onDeleteSelection: () {
                                              setState(() {
                                                errorFileUpload = false;
                                                geojsonFromFile = {};
                                              });
                                            },
                                            onFileAdded: (Map<String, dynamic>
                                                fileContent) {
                                              setState(() {
                                                geojsonFromFile = fileContent;
                                                errorFileUpload = false;
                                              });
                                            },
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Visibility(
                                visible: widget.isEdit && isZoneLoaded,
                                child: Column(children: [
                                  Text(
                                    appLocalizations.inspect_map_title,
                                    style: const TextStyle(fontSize: 16.0),
                                  ),
                                  const SizedBox(height: 12),
                                  CustomElevatedButton(
                                    onPressed: () async {
                                      _showMapElement(context);
                                    },
                                    text: appLocalizations.see_map_button,
                                  ),
                                  const SizedBox(height: 12),
                                  Visibility(
                                      visible: kIsWeb,
                                      child: Column(children: [
                                        Text(
                                          'Reportes',
                                          style:
                                              const TextStyle(fontSize: 16.0),
                                        ),
                                        ReportComponent(
                                            scheduledId: widget.scheduledId!),
                                        const SizedBox(height: 12),
                                      ])),
                                ]),
                              ),
                              Visibility(
                                visible: creatingScheduled &&
                                    !creatingScheduledError,
                                child: Container(
                                  width: widthRow * 0.6,
                                  height:
                                      zoneLoadViewModel.processAlreadyRunning ||
                                              zoneLoadViewModel.warning
                                          ? 150
                                          : zoneLoadViewModel.result != null
                                              ? 202
                                              : 258,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: SizedBox(
                                    child: zoneLoadViewModel.warning
                                        ? Column(children: [
                                            Visibility(
                                              visible: zoneLoadViewModel
                                                  .processAlreadyRunning,
                                              child: Column(children: [
                                                Text(
                                                  appLocalizations
                                                      .scheduled_process_ejecuting,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                ),
                                                const SizedBox(height: 24),
                                                CustomElevatedButton(
                                                    showLoading:
                                                        zoneLoadViewModel
                                                            .isRetrying,
                                                    loadingDuration: 1000,
                                                    onPressed: () async {
                                                      await zoneLoadViewModel.retryProcess(
                                                          token: token,
                                                          operation: 'start',
                                                          type:
                                                              'SCHEDULED_CHARGE',
                                                          id: taskScheduledResponse!
                                                              .id!);
                                                    },
                                                    text: appLocalizations
                                                        .retry_button)
                                              ]),
                                            ),
                                            Visibility(
                                              visible: zoneLoadViewModel.error,
                                              child: Column(children: [
                                                Text(
                                                  appLocalizations
                                                      .scheduled_process_error,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                ),
                                                const SizedBox(height: 24),
                                                CustomElevatedButton(
                                                    showLoading:
                                                        zoneLoadViewModel
                                                            .isRetrying,
                                                    loadingDuration: 1000,
                                                    onPressed: () async {
                                                      await zoneLoadViewModel.retryProcess(
                                                          token: token,
                                                          operation: 'start',
                                                          type:
                                                              'SCHEDULED_CHARGE',
                                                          id: taskScheduledResponse!
                                                              .id!);
                                                    },
                                                    text: appLocalizations
                                                        .retry_button)
                                              ]),
                                            ),
                                          ])
                                        : Visibility(
                                            key: UniqueKey(),
                                            visible: true,
                                            child: Column(
                                              children: [
                                                Visibility(
                                                  visible: (geojsonFromFile
                                                              .isNotEmpty &&
                                                          (!zoneLoadViewModel
                                                                  .error &&
                                                              zoneLoadViewModel
                                                                      .result ==
                                                                  null)) ||
                                                      (geojsonFromFile
                                                              .isEmpty &&
                                                          taskListScheduledViewModel
                                                              .isLoading),
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        appLocalizations
                                                            .file_upload_message_information,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Visibility(
                                                        visible: (geojsonFromFile
                                                                    .isNotEmpty &&
                                                                (zoneLoadViewModel
                                                                        .isLoading ||
                                                                    !zoneLoadViewModel
                                                                        .connected)) ||
                                                            (geojsonFromFile
                                                                    .isEmpty &&
                                                                taskListScheduledViewModel
                                                                    .isLoading),
                                                        child: Center(
                                                          child:
                                                              LoadingAnimationWidget
                                                                  .waveDots(
                                                            color:
                                                                primarySwatch[
                                                                    400]!,
                                                            size: 36,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                TaskCreationStatusRow(
                                                  title: appLocalizations
                                                      .file_upload_creating_scheduled,
                                                  isLoading:
                                                      taskListScheduledViewModel
                                                          .isLoading,
                                                  iconCheck:
                                                      taskScheduledResponse !=
                                                          null,
                                                ),
                                                Visibility(
                                                  visible: geojsonFromFile
                                                      .isNotEmpty,
                                                  child: TaskCreationStatusRow(
                                                    title: appLocalizations
                                                        .file_upload_creating_zone,
                                                    isLoading:
                                                        scheduledViewModel
                                                            .isLoading,
                                                    iconCheck:
                                                        zoneCreated != null &&
                                                            zoneCreated!,
                                                  ),
                                                ),
                                                Visibility(
                                                  visible:
                                                      zoneCreated != null &&
                                                          zoneCreated!,
                                                  child: TaskCreationStatusRow(
                                                    title: appLocalizations
                                                        .file_upload_starting_elements_load,
                                                    isLoading:
                                                        !zoneLoadViewModel
                                                            .connected,
                                                    iconCheck: zoneLoadViewModel
                                                        .connected,
                                                  ),
                                                ),
                                                Visibility(
                                                  visible: zoneLoadViewModel
                                                          .connected ||
                                                      zoneLoadViewModel
                                                              .result !=
                                                          null,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      TaskCreationStatusRow(
                                                        title: appLocalizations
                                                            .file_upload_adding_sections,
                                                        isLoading:
                                                            zoneLoadViewModel
                                                                .isLoadingSections,
                                                        iconCheck:
                                                            zoneLoadViewModel
                                                                .sectionsResult,
                                                      ),
                                                      TaskCreationStatusRow(
                                                        title: appLocalizations
                                                            .file_upload_adding_catchments,
                                                        isLoading: zoneLoadViewModel
                                                            .isLoadingCatchments,
                                                        iconCheck:
                                                            zoneLoadViewModel
                                                                .catchmentsResult,
                                                      ),
                                                      TaskCreationStatusRow(
                                                        title: appLocalizations
                                                            .file_upload_adding_registers,
                                                        isLoading: zoneLoadViewModel
                                                            .isLoadingRegisters,
                                                        iconCheck:
                                                            zoneLoadViewModel
                                                                .registersResult,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                if (zoneLoadViewModel.error)
                                                  Text(
                                                    'Error: ${zoneLoadViewModel.message}',
                                                    style: TextStyle(
                                                        fontSize:
                                                            fontCreateTask),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                const SizedBox(height: 24),
                                                if (zoneLoadViewModel.result !=
                                                    null)
                                                  Text(
                                                    zoneLoadViewModel.result!
                                                        ? appLocalizations
                                                            .file_upload_success
                                                        : appLocalizations
                                                            .file_upload_error,
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: zoneLoadViewModel
                                                                .result!
                                                            ? primarySwatch[600]
                                                            : redColor,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                    textAlign: TextAlign.center,
                                                  ),
                                              ],
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: creatingScheduledError,
                                child: Container(
                                  width: widthRow * 0.6,
                                  height: 172,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                          appLocalizations
                                              .scheduled_process_creating_error,
                                          style: TextStyle(
                                              fontSize: fontCreateTask),
                                          textAlign: TextAlign.center),
                                      const SizedBox(height: 8),
                                      const Icon(
                                        Icons.error,
                                        color: Colors.red,
                                        size: 42,
                                      ),
                                      const SizedBox(height: 8),
                                      CustomElevatedButton(
                                          onPressed: () {
                                            handleSubmit();
                                          },
                                          text: appLocalizations.retry_button),
                                      const SizedBox(height: 8),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.taskColumnSpace),
                      Visibility(
                        visible: !creatingScheduled &&
                            isAdmin &&
                            !creatingScheduledError,
                        child: CustomElevatedButton(
                          onPressed: () async {
                            if (geojsonFromFile.isEmpty) {
                              setState(() {
                                errorFileUpload = true;
                              });
                            }
                            if (_formKey.currentState!.validate()) {
                              widget.isEdit ? handleEdit() : handleSubmit();
                            }
                          },
                          text: widget.isEdit
                              ? appLocalizations.buttonAcceptLabel
                              : appLocalizations.createTaskPage_submitButton,
                        ),
                      ),
                    ],
                  ),
                ),
              ]));
        });
      });
    });
  }
}

class TaskCreationStatusRow extends StatelessWidget {
  final bool isLoading;
  final bool iconCheck;
  final String title;

  const TaskCreationStatusRow({
    Key? key,
    required this.isLoading,
    required this.iconCheck,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double fontCreateTask = 16.0;
    double iconCreateResult = 18;
    double sizeWaveDots = 30;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Visibility(
          visible: !isLoading,
          child: iconCheck
              ? Icon(
                  Icons.check_circle,
                  color: primarySwatch[400]!,
                  size: iconCreateResult,
                )
              : Icon(
                  Icons.error,
                  color: !isLoading ? Colors.transparent : Colors.red,
                  size: iconCreateResult,
                ),
        ),
        const SizedBox(width: 4),
        Text(
          title,
          style: TextStyle(fontSize: fontCreateTask),
        ),
        Visibility(
          visible: isLoading,
          child: Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 0, top: 0),
            child: LoadingAnimationWidget.horizontalRotatingDots(
              color: primarySwatch[400]!,
              size: sizeWaveDots,
            ),
          ),
        ),
      ],
    );
  }
}
