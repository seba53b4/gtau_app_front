import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtau_app_front/models/enums/message_type.dart';
import 'package:gtau_app_front/models/task_status.dart';
import 'package:gtau_app_front/navigation/navigation_web.dart';
import 'package:gtau_app_front/providers/user_provider.dart';
import 'package:gtau_app_front/viewmodels/catchment_viewmodel.dart';
import 'package:gtau_app_front/viewmodels/lot_viewmodel.dart';
import 'package:gtau_app_front/viewmodels/register_viewmodel.dart';
import 'package:gtau_app_front/viewmodels/task_list_scheduled_viewmodel.dart';
import 'package:gtau_app_front/viewmodels/user_list_viewmodel.dart';
import 'package:gtau_app_front/widgets/common/box_container.dart';
import 'package:gtau_app_front/widgets/common/customMessageDialog.dart';
import 'package:gtau_app_front/widgets/common/informe_upload_component.dart';
import 'package:gtau_app_front/widgets/loading_overlay.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../constants/theme_constants.dart';
import '../dto/image_data.dart';
import '../models/task.dart';
import '../navigation/navigation.dart';
import '../providers/selected_items_provider.dart';
import '../providers/task_filters_provider.dart';
import '../utils/common_utils.dart';
import '../utils/date_utils.dart';
import '../utils/imagesbundle.dart';
import '../viewmodels/images_viewmodel.dart';
import '../viewmodels/section_viewmodel.dart';
import '../viewmodels/task_list_viewmodel.dart';
import '../widgets/common/customDialog.dart';
import '../widgets/common/custom_dropdown.dart';
import '../widgets/common/custom_elevated_button.dart';
import '../widgets/common/custom_text_form_field.dart';
import '../widgets/common/custom_toggle_buttons.dart';
import '../widgets/common/inspection_location_select.dart';
import '../widgets/common/task_creation/create_scheduled.dart';
import '../widgets/common/task_creation/element_selected.dart';
import '../widgets/task_image_gallery_modal.dart';

class TaskCreationScreen extends StatefulWidget {
  var type = 'inspection';
  bool detail = false;
  int? idTask = 0;
  final bool scheduledEdit;

  TaskCreationScreen(
      {super.key,
      required this.type,
      this.detail = false,
      this.idTask = 0,
      this.scheduledEdit = false});

  @override
  _TaskCreationScreenState createState() => _TaskCreationScreenState();
}

class _TaskCreationScreenState extends State<TaskCreationScreen> {
  late Task task;
  late DateTime? startDate;
  late DateTime? releasedDate;
  int selectedIndex = 0;
  static const String notAssigned = "Sin asignar";
  String userAssigned = notAssigned;
  late String taskStatus = 'PENDING';
  late String initStatus = 'PENDING';
  final descriptionController = TextEditingController();
  final numWorkController = TextEditingController();
  final locationController = TextEditingController();
  final scheduledNumberController = TextEditingController();
  final contactController = TextEditingController();
  final applicantController = TextEditingController();
  final lengthController = TextEditingController();
  final materialController = TextEditingController();
  final observationsController = TextEditingController();
  final conclusionsController = TextEditingController();
  final addDateController = TextEditingController();
  final releasedDateController = TextEditingController();
  late UserListViewModel userListViewModel;
  late String token;
  late List<String> listUsers = [notAssigned];

  SelectedItemsProvider? selectedItemsProvider;

  String numOrder = "";

  void reset() {
    descriptionController.text = '';
    numWorkController.text = '';
    locationController.text = '';
    scheduledNumberController.text = '';
    contactController.text = '';
    applicantController.text = '';
    lengthController.text = '';
    materialController.text = '';
    observationsController.text = '';
    conclusionsController.text = '';
    addDateController.text = '';
    releasedDateController.text = '';
    setState(() {
      userAssigned = notAssigned;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    descriptionController.dispose();
    numWorkController.dispose();
    locationController.dispose();
    scheduledNumberController.dispose();
    contactController.dispose();
    applicantController.dispose();
    lengthController.dispose();
    materialController.dispose();
    observationsController.dispose();
    conclusionsController.dispose();
    addDateController.dispose();
    releasedDateController.dispose();
    _scrollController.dispose();
    selectedItemsProvider?.reset();
    super.dispose();
  }

  void clearElementsFetched() {
    context.read<RegisterViewModel>().reset();
    context.read<SectionViewModel>().reset();
    context.read<LotViewModel>().reset();
    context.read<CatchmentViewModel>().reset();
  }

  void _SoftClearPref() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("is_loading", false);
    prefs.setInt("actual_page", 1);
  }

  @override
  void initState() {
    super.initState();
    selectedItemsProvider = context.read<SelectedItemsProvider>();
    userListViewModel = Provider.of<UserListViewModel>(context, listen: false);
    token = Provider.of<UserProvider>(context, listen: false).getToken!;
    if (!widget.scheduledEdit) {
      _listUserNames();
    }
    if (widget.detail) {
      widget.type == 'inspection' ? selectedIndex = 1 : selectedIndex = 0;
      releasedDate = DateTime.now();
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // Llama a updateTaskListState después de que la construcción del widget haya finalizado.
        if (!widget.scheduledEdit) {
          await initializeTask();
        }
      });
    } else {
      startDate = DateTime.now();
    }
  }

  void _listUserNames() async {
    try {
      final response = await userListViewModel
          .fetchUsernames(context)
          .catchError((error) async {
        // Manejo de error
        showCustomMessageDialog(
          context: context,
          customText: AppLocalizations.of(context)!.listuser_user_notfound,
          onAcceptPressed: () {},
          messageType: DialogMessageType.error,
        );
        return null;
      });
      if (response != null) {
        listUsers.addAll(response);
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      throw Exception('Error _listUserNames');
    }
  }

  Future<bool> _fetchTask() async {
    final token = Provider.of<UserProvider>(context, listen: false).getToken;
    final taskListViewModel =
        Provider.of<TaskListViewModel>(context, listen: false);

    try {
      final selectedItemsProvider = context.read<SelectedItemsProvider>();
      final responseTask =
          await taskListViewModel.fetchTask(token, widget.idTask!);
      if (responseTask != null) {
        task = responseTask;
      }

      selectedItemsProvider.saveInitialSelections(task.sections, task.registers,
          task.catchments, task.lots, task.position!);
      numWorkController.text = task.workNumber!;
      descriptionController.text = task.description!;
      applicantController.text = task.applicant!;
      locationController.text = task.location!;
      setState(() {
        userAssigned = task.user!;
      });
      lengthController.text = task.length ?? '';
      materialController.text = task.material ?? '';
      conclusionsController.text = task.conclusions ?? '';
      observationsController.text = task.observations ?? '';
      startDate = task.addDate!;
      taskStatus = task.status!;
      initStatus = task.status!;
      if (task.releasedDate != null) {
        releasedDate = task.releasedDate!;
        releasedDateController.text = parseDateTimeOnFormat(task.releasedDate!);
      }
      addDateController.text = parseDateTimeOnFormat(task.addDate!);

      return true;
    } catch (error) {
      printOnDebug(error.toString());
      throw Exception('Error al obtener los datos');
    }
  }

  Future<bool> _createTask(Map<String, dynamic> body) async {
    final token = Provider.of<UserProvider>(context, listen: false).getToken;
    final taskListViewModel =
        Provider.of<TaskListViewModel>(context, listen: false);
    try {
      final response = await taskListViewModel.createTask(token!, body);
      if (response) {
        printOnDebug('Tarea ha sido creada correctamente');
        await showMessageDialog(DialogMessageType.success);
        return true;
      } else {
        await showMessageDialog(DialogMessageType.error);
        printOnDebug('No se pudieron traer datos');
        return false;
      }
    } catch (error) {
      printOnDebug(error.toString());
      throw Exception('Error al obtener los datos');
    }
  }

  Future<bool> _updateTask(Map<String, dynamic> body) async {
    if (Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ImageBundleAdapter());
    }
    final token = Provider.of<UserProvider>(context, listen: false).getToken;

    final taskListViewModel =
        Provider.of<TaskListViewModel>(context, listen: false);

    try {
      final response =
          await taskListViewModel.updateTask(token!, widget.idTask!, body);

      if (response) {
        printOnDebug('Tarea ha sido actualizada correctamente');
        await showMessageDialog(DialogMessageType.success);
        return true;
      } else {
        printOnDebug('No se pudieron traer datos');
        await showMessageDialog(DialogMessageType.error);
        return false;
      }
    } catch (error) {
      printOnDebug(error.toString());
      throw Exception('Error al obtener los datos');
    }
  }

  Future<void> showMessageDialog(DialogMessageType type) async {
    await showCustomMessageDialog(
        context: context,
        messageType: type,
        onAcceptPressed: () {
          if (type == DialogMessageType.success && !widget.detail) {
            final isAdmin = context.read<UserProvider>().isAdmin;
            Widget nav = kIsWeb
                ? NavigationWeb(isAdmin: isAdmin != null && isAdmin)
                : const BottomNavigation();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => nav),
            );
          }
        });
  }

  Future<void> initializeTask() async {
    await _fetchTask().catchError((error) async {
      // Manejo de error
      await showCustomMessageDialog(
        context: context,
        onAcceptPressed: () {
          Navigator.of(context).pop();
        },
        customText: AppLocalizations.of(context)!.error_generic_text,
        messageType: DialogMessageType.error,
      );
    });
  }

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<bool> _ResetPrefs() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.clear();
  }

  void handleStartDateChange(DateTime date) {
    setState(() {
      startDate = date;
    });
    addDateController.text = parseDateTimeOnFormat(date);
  }

  void handleReleasedDateChange(DateTime dateReleased) {
    setState(() {
      releasedDate = dateReleased;
    });
    releasedDateController.text = parseDateTimeOnFormat(dateReleased);
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
        onEnablePressed: () async {
          Navigator.of(context).pop();
          await handleAcceptOnShowDialogCreateTask();
        },
        acceptButtonLabel: AppLocalizations.of(context)!.dialogAcceptButton,
        cancelbuttonLabel: AppLocalizations.of(context)!.dialogCancelButton,
      );
    } else {
      printOnDebug(
          'Programada: ${scheduledNumberController.text} Descripcion: ${descriptionController.text}');
    }
  }

  Map<String, dynamic> createBodyToCreate() {
    var selectedItemsProvider = context.read<SelectedItemsProvider>();
    final selectedSections = selectedItemsProvider.selectedPolylines;
    final List<String> listSelectedSections =
        selectedSections.map((polylineId) => polylineId.value).toList();

    final selectedCatchments = selectedItemsProvider.selectedCatchments;
    final List<String> listSelectedCatchments =
        selectedCatchments.map((circleId) => circleId.value).toList();

    final selectedRegisters = selectedItemsProvider.selectedRegisters;
    final List<String> listSelectedRegisters =
        selectedRegisters.map((circleId) => circleId.value).toList();

    final selectedLots = selectedItemsProvider.selectedLots;
    final List<String> listSelectedLots =
        selectedLots.map((polylineId) => polylineId.value).toList();

    final Map<String, dynamic> position = {
      "latitud": selectedItemsProvider.inspectionPosition.longitude.toString(),
      "longitud": selectedItemsProvider.inspectionPosition.longitude.toString()
    };

    late String addDateUpdated = formattedDate(addDateController.text);
    final Map<String, dynamic> requestBody = {
      "status": taskStatus,
      "inspectionType": "inspectionType Default",
      "workNumber": numWorkController.text,
      "addDate": addDateUpdated,
      "applicant": applicantController.text,
      "location": locationController.text,
      "description": descriptionController.text,
      "user": userAssigned,
      "tramos": listSelectedSections,
      "captaciones": listSelectedCatchments,
      "registros": listSelectedRegisters,
      "parcelas": listSelectedLots,
      "position": position
    };
    return requestBody;
  }

  Map<String, dynamic> createBodyToUpdate() {
    late String addDateUpdated = formattedDate(addDateController.text);
    late String? releasedDateSelected = releasedDateController.text.isNotEmpty
        ? formattedDate(releasedDateController.text)
        : null;

    var selectedItemsProvider = context.read<SelectedItemsProvider>();

    final selectedSections = selectedItemsProvider.selectedPolylines;
    final List<String> listSelectedSections =
        selectedSections.map((polylineId) => polylineId.value).toList();
    final selectedCatchments = selectedItemsProvider.selectedCatchments;
    final List<String> listSelectedCatchments =
        selectedCatchments.map((circleId) => circleId.value).toList();
    final selectedRegisters = selectedItemsProvider.selectedRegisters;
    final List<String> listSelectedRegisters =
        selectedRegisters.map((circleId) => circleId.value).toList();
    final selectedLots = selectedItemsProvider.selectedLots;
    final List<String> listSelectedLots =
        selectedLots.map((polylineId) => polylineId.value).toList();

    final Map<String, dynamic> position = {
      "latitud": selectedItemsProvider.inspectionPosition.latitude,
      "longitud": selectedItemsProvider.inspectionPosition.longitude
    };

    final Map<String, dynamic> requestBody = {
      "status": taskStatus,
      "inspectionType": task.inspectionType,
      "workNumber": numWorkController.text,
      "addDate": addDateUpdated,
      "applicant": applicantController.text,
      "location": locationController.text,
      "description": descriptionController.text,
      "releasedDate": releasedDateSelected,
      "user": userAssigned,
      "length": lengthController.text,
      "material": materialController.text,
      "observations": observationsController.text,
      "conclusions": conclusionsController.text,
      "tramos": listSelectedSections,
      "captaciones": listSelectedCatchments,
      "registros": listSelectedRegisters,
      "parcelas": listSelectedLots,
      "position": position
    };
    return requestBody;
  }

  Future handleAcceptOnShowDialogEditTask() async {
    Map<String, dynamic> requestBody = createBodyToUpdate();
    bool isUpdated = await _updateTask(requestBody);
    this.processImages();
    if (isUpdated) {
      reset();
    }
    clearElementsFetched();
    _ResetPrefs();
    await updateTaskList();
  }

  void processImages() {
    if (this.imagesFiles != null) {
      final token = Provider.of<UserProvider>(context, listen: false).getToken;
      final imagesViewModel =
          Provider.of<ImagesViewModel>(context, listen: false);
      this.imagesFiles!.forEach((image) async {
        try {
          final response = await imagesViewModel.uploadImage(
              token!, widget.idTask!, image.getPath);
        } catch (error) {
          printOnDebug(error.toString());
          throw Exception('Error al subir imagen');
        }
      });
    }
  }

  Future handleAcceptOnShowDialogCreateTask() async {
    Map<String, dynamic> requestBody = createBodyToCreate();
    bool isUpdated = await _createTask(requestBody);
    if (isUpdated) {
      reset();
    }
    clearElementsFetched();
    _ResetPrefs();
    await updateTaskList();
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

    final scheduledListViewModel =
        Provider.of<TaskListScheduledViewModel>(context, listen: false);
    final token = Provider.of<UserProvider>(context, listen: false).getToken;
    scheduledListViewModel.clearListByStatus(status!);
    await scheduledListViewModel.fetchScheduledTasks(token!, status);
  }

  Future updateTaskList() async {
    final taskFilterProvider =
        Provider.of<TaskFilterProvider>(context, listen: false);
    final userName =
        Provider.of<TaskFilterProvider>(context, listen: false).userNameFilter;
    final taskListViewModel =
        Provider.of<TaskListViewModel>(context, listen: false);
    final status = taskFilterProvider.lastStatus;
    taskListViewModel.clearListByStatus(status!);
    await taskListViewModel.initializeTasks(context, status, userName);

    final scheduledListViewModel =
        Provider.of<TaskListScheduledViewModel>(context, listen: false);
    final token = Provider.of<UserProvider>(context, listen: false).getToken;
    scheduledListViewModel.clearListByStatus(status!);
    await scheduledListViewModel.fetchScheduledTasks(token!, status);
  }

  void handleEditTask() {
    showCustomDialog(
      context: context,
      title: AppLocalizations.of(context)!.dialogWarning,
      content: AppLocalizations.of(context)!.dialogContent,
      onDisablePressed: () {
        Navigator.of(context).pop();
      },
      onEnablePressed: () async {
        Navigator.of(context).pop();
        await handleAcceptOnShowDialogEditTask();
        Navigator.of(context).pop();
      },
      acceptButtonLabel: AppLocalizations.of(context)!.dialogAcceptButton,
      cancelbuttonLabel: AppLocalizations.of(context)!.dialogCancelButton,
    );
  }

  void resetSelectionOnMap() {
    selectedItemsProvider?.restoreInitialValues();
  }

  void handleCancel() {
    resetSelectionOnMap();
    clearElementsFetched();
    Navigator.of(context).pop();
  }

  List<ImageDataDTO>? imagesFiles = null;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  void scrollToTopScrollView() {
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    double widthRow = 640;
    double heightRow = 128;

    return Consumer<TaskListViewModel>(
        builder: (context, taskListViewModel, child) {
      return Consumer<UserListViewModel>(
          builder: (context, userListViewModel, child) {
        return LoadingOverlay(
          isLoading: taskListViewModel.isLoading || userListViewModel.isLoading,
          child: Scaffold(
            body: SingleChildScrollView(
              controller: _scrollController,
              child: Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: 12.0, vertical: 12.0),
                child: Column(
                  children: [
                    Visibility(
                      visible: widget.detail && selectedIndex == 1 && kIsWeb,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 12, 0, 0),
                          child: FloatingActionButton(
                            foregroundColor: primarySwatch,
                            backgroundColor: lightBackground,
                            onPressed: () {
                              handleCancel();
                            },
                            tooltip: AppLocalizations.of(context)!
                                .placeholder_back_button,
                            child: const Icon(Icons.arrow_back),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    Visibility(
                      visible: !widget.detail,
                      child: CustomToggleButtons(
                        onPressedList: [
                          () {
                            setState(() {
                              selectedIndex = 0;
                            });
                          },
                          () {
                            setState(() {
                              selectedIndex = 1;
                            });
                          }
                        ],
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Visibility(
                      visible: selectedIndex == 1 && kIsWeb,
                      child: Form(
                        key: _formKey,
                        child: BoxContainer(
                          width: widthRow * 1.15,
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                AppLocalizations.of(context)!
                                    .taskInformationTitle,
                                style: const TextStyle(fontSize: 32.0),
                              ),
                              const SizedBox(height: 24.0),
                              // Primera fila

                              SizedBox(
                                height: heightRow,
                                width: widthRow,
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)!
                                                .createTaskPage_numberWorkTitle,
                                            style:
                                                const TextStyle(fontSize: 16.0),
                                          ),
                                          const SizedBox(
                                              height:
                                                  AppConstants.taskColumnSpace),
                                          CustomTextFormField(
                                            readOnly: widget.detail,
                                            hintText: AppLocalizations.of(
                                                    context)!
                                                .createTaskPage_numberWorkTitle,
                                            controller: numWorkController,
                                            textInputType: TextInputType.number,
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          const SizedBox(
                                              width: AppConstants.taskRowSpace),
                                          Column(
                                            children: [
                                              Text(
                                                AppLocalizations.of(context)!
                                                    .createTaskPage_assignedUserTitle,
                                                style: const TextStyle(
                                                    fontSize: 16.0),
                                              ),
                                              const SizedBox(height: 12.0),
                                              CustomDropdown(
                                                value: (listUsers.contains(
                                                            userAssigned) ==
                                                        true)
                                                    ? userAssigned
                                                    : notAssigned,
                                                items: listUsers,
                                                onChanged: (String? value) {
                                                  setState(() {
                                                    userAssigned = value!;
                                                  });
                                                },
                                              ),
                                              const SizedBox(
                                                  height: AppConstants
                                                      .taskColumnSpace),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Column(children: [
                                        Text(
                                          AppLocalizations.of(context)!
                                              .editTaskPage_statusTitle,
                                          style:
                                              const TextStyle(fontSize: 16.0),
                                        ),
                                        const SizedBox(height: 12.0),
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
                                        const SizedBox(
                                            height:
                                                AppConstants.taskColumnSpace),
                                      ]),
                                    ]),
                              ),
                              // Segunda fila
                              SizedBox(
                                height: heightRow,
                                width: widthRow,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!
                                              .createTaskPage_startDateTitle,
                                          style:
                                              const TextStyle(fontSize: 16.0),
                                        ),
                                        const SizedBox(height: 12.0),
                                        SizedBox(
                                          width: AppConstants.textFieldWidth,
                                          child: InkWell(
                                            overlayColor:
                                                MaterialStateColor.resolveWith(
                                                    (states) =>
                                                        Colors.transparent),
                                            onTap: () async {
                                              final DateTime? pickedDate =
                                                  await showCustomDatePicker(
                                                      context, startDate!);
                                              if (pickedDate != null) {
                                                handleStartDateChange(
                                                    pickedDate);
                                              }
                                            },
                                            child: IgnorePointer(
                                              child: CustomTextFormField(
                                                width:
                                                    AppConstants.taskRowSpace,
                                                hintText: AppLocalizations.of(
                                                        context)!
                                                    .createTaskPage_startDateTitle,

                                                controller: addDateController,
                                                // enabled: false,
                                                // readOnly: true,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                        width: AppConstants.taskRowSpace),
                                    Column(
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!
                                              .createTaskPage_solicitantTitle,
                                          style:
                                              const TextStyle(fontSize: 16.0),
                                        ),
                                        const SizedBox(height: 12.0),
                                        CustomTextFormField(
                                          width:
                                              AppConstants.textFieldWidth * 2 +
                                                  AppConstants.taskRowSpace,
                                          hintText: AppLocalizations.of(
                                                  context)!
                                              .createTaskPage_solicitantPlaceholder,
                                          controller: applicantController,
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              //const SizedBox(height: 20.0),
                              // Tercera fila
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!
                                        .createTaskPage_selectAddressTitle,
                                    style: const TextStyle(fontSize: 16.0),
                                  ),
                                  const SizedBox(height: 12.0),
                                  CustomTextFormField(
                                    width: widthRow,
                                    hintText: AppLocalizations.of(context)!
                                        .createTaskPage_selectAddressplaceholder,
                                    controller: locationController,
                                  ),
                                  const SizedBox(
                                      width: AppConstants.taskRowSpace),
                                  Text(
                                    AppLocalizations.of(context)!
                                        .default_descriptionTitle,
                                    style: const TextStyle(fontSize: 16.0),
                                  ),
                                  const SizedBox(height: 12.0),
                                  CustomTextFormField(
                                    isTextBox: true,
                                    maxLines: 10,
                                    width: widthRow,
                                    height: heightRow,
                                    hintText: AppLocalizations.of(context)!
                                        .default_descriptionPlaceholder,
                                    controller: descriptionController,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: selectedIndex == 1 && !kIsWeb,
                      child: Form(
                        key: _formKey,
                        child: BoxContainer(
                          width: widthRow * 1.15,
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                AppLocalizations.of(context)!
                                    .taskInformationTitle,
                                style: const TextStyle(fontSize: 24.0),
                              ),
                              const SizedBox(height: 16.0),
                              // Primera fila
                              SizedBox(
                                height: 100,
                                width: widthRow,
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)!
                                                .createTaskPage_numberWorkTitle,
                                            style:
                                                const TextStyle(fontSize: 12.0),
                                          ),
                                          const SizedBox(
                                              height:
                                                  AppConstants.taskColumnSpace),
                                          CustomTextFormField(
                                            width: 148,
                                            height: 54,
                                            fontSize: 12,
                                            readOnly: widget.detail,
                                            hintText: AppLocalizations.of(
                                                    context)!
                                                .createTaskPage_numberWorkTitle,
                                            controller: numWorkController,
                                            textInputType: TextInputType.number,
                                          ),
                                        ],
                                      ),
                                      Column(children: [
                                        Text(
                                          AppLocalizations.of(context)!
                                              .editTaskPage_statusTitle,
                                          style:
                                              const TextStyle(fontSize: 12.0),
                                        ),
                                        const SizedBox(height: 12.0),
                                        CustomDropdown(
                                          isStatus: true,
                                          width: 148,
                                          //height: 54,
                                          fontSize: 12,
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
                                        // const SizedBox(
                                        //     height: AppConstants.taskColumnSpace),
                                      ]),
                                    ]),
                              ),
                              const SizedBox(height: 20.0),
                              // Segunda fila
                              SizedBox(
                                  height: 100,
                                  width: widthRow,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)!
                                                .createTaskPage_startDateTitle,
                                            style:
                                                const TextStyle(fontSize: 12.0),
                                          ),
                                          const SizedBox(height: 12.0),
                                          SizedBox(
                                            width: 148,
                                            child: InkWell(
                                              overlayColor: MaterialStateColor
                                                  .resolveWith((states) =>
                                                      Colors.transparent),
                                              onTap: () async {
                                                final DateTime? pickedDate =
                                                    await showCustomDatePicker(
                                                        context, startDate!);
                                                if (pickedDate != null) {
                                                  handleStartDateChange(
                                                      pickedDate);
                                                }
                                              },
                                              child: IgnorePointer(
                                                child: CustomTextFormField(
                                                  width: 128,
                                                  height: 54,
                                                  fontSize: 12,
                                                  hintText: AppLocalizations.of(
                                                          context)!
                                                      .createTaskPage_startDateTitle,

                                                  controller: addDateController,
                                                  // enabled: false,
                                                  // readOnly: true,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)!
                                                .createTaskPage_assignedUserTitle,
                                            style:
                                                const TextStyle(fontSize: 12.0),
                                          ),
                                          const SizedBox(height: 12.0),
                                          CustomDropdown(
                                              width: 148,
                                              //height: 54,
                                              fontSize: 12,
                                              value: (listUsers.contains(
                                                          userAssigned) ==
                                                      true)
                                                  ? userAssigned
                                                  : notAssigned,
                                              items: listUsers,
                                              onChanged: (String? value) {
                                                setState(() {
                                                  userAssigned = value!;
                                                });
                                              }),
                                          const SizedBox(
                                              width:
                                                  AppConstants.taskColumnSpace),
                                        ],
                                      ),
                                    ],
                                  )),
                              const SizedBox(height: 20.0),
                              // Tercera columna
                              SizedBox(
                                height: 120,
                                width: widthRow,
                                child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)!
                                                .createTaskPage_solicitantTitle,
                                            style:
                                                const TextStyle(fontSize: 14.0),
                                          ),
                                          const SizedBox(height: 12.0),
                                          CustomTextFormField(
                                            width: widthRow + 24,
                                            height: 80,
                                            fontSize: 12,
                                            hintText: AppLocalizations.of(
                                                    context)!
                                                .createTaskPage_solicitantPlaceholder,
                                            controller: applicantController,
                                          ),
                                        ],
                                      )
                                    ]),
                              ),
                              // const SizedBox(height: 8),
                              // Cuarta columna
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!
                                        .createTaskPage_selectAddressTitle,
                                    style: const TextStyle(fontSize: 14.0),
                                  ),
                                  const SizedBox(height: 12.0),
                                  CustomTextFormField(
                                    width: widthRow + 24,
                                    height: 80,
                                    fontSize: 12,
                                    hintText: AppLocalizations.of(context)!
                                        .createTaskPage_selectAddressplaceholder,
                                    controller: locationController,
                                  ),
                                  //      const SizedBox(height: 12.0),
                                  Text(
                                    AppLocalizations.of(context)!
                                        .default_descriptionTitle,
                                    style: const TextStyle(fontSize: 14.0),
                                  ),
                                  const SizedBox(height: 12.0),
                                  CustomTextFormField(
                                    isTextBox: true,
                                    maxLines: 10,
                                    fontSize: 12,
                                    width: widthRow,
                                    height: heightRow,
                                    hintText: AppLocalizations.of(context)!
                                        .default_descriptionPlaceholder,
                                    controller: descriptionController,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                        visible: selectedIndex == 0,
                        child: ScheduledComponent(
                          isEdit: widget.detail,
                          scheduledId: widget.idTask!,
                        )),
                    Visibility(
                      visible: widget.detail && selectedIndex == 1,
                      child: Container(
                        width: widthRow * 1.15,
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.taskInspectionTitle,
                              style:
                                  const TextStyle(fontSize: kIsWeb ? 32.0 : 24),
                            ),
                            const SizedBox(height: 24.0),
                            kIsWeb
                                ? SizedBox(
                                    height: 128,
                                    width: widthRow,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Column(
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!
                                                  .createTaskPage_realizationDateTitle,
                                              style: const TextStyle(
                                                  fontSize: 16.0),
                                            ),
                                            const SizedBox(height: 10.0),
                                            SizedBox(
                                              width:
                                                  AppConstants.textFieldWidth,
                                              child: InkWell(
                                                overlayColor: MaterialStateColor
                                                    .resolveWith((states) =>
                                                        Colors.transparent),
                                                onTap: () async {
                                                  final DateTime? pickedDate =
                                                      await showCustomDatePicker(
                                                          context, startDate!);
                                                  if (pickedDate != null) {
                                                    handleReleasedDateChange(
                                                        pickedDate);
                                                  }
                                                },
                                                child: IgnorePointer(
                                                  child: CustomTextFormField(
                                                    useValidation: false,
                                                    width: AppConstants
                                                        .textFieldWidth,
                                                    hintText: AppLocalizations
                                                            .of(context)!
                                                        .default_datepicker_hint,
                                                    controller:
                                                        releasedDateController,
                                                    //enabled: false,
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!
                                                  .createTaskPage_longitudeTitle,
                                              style: const TextStyle(
                                                  fontSize: 16.0),
                                            ),
                                            const SizedBox(height: 10.0),
                                            CustomTextFormField(
                                              useValidation: false,
                                              width:
                                                  AppConstants.textFieldWidth,
                                              textInputType:
                                                  TextInputType.number,
                                              hintText: AppLocalizations.of(
                                                      context)!
                                                  .createTaskPage_longitudeTitle,
                                              controller: lengthController,
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!
                                                  .createTaskPage_materialTitle,
                                              style: const TextStyle(
                                                  fontSize: 16.0),
                                            ),
                                            const SizedBox(height: 10.0),
                                            CustomTextFormField(
                                              useValidation: false,
                                              width:
                                                  AppConstants.textFieldWidth,
                                              hintText: AppLocalizations.of(
                                                      context)!
                                                  .createTaskPage_materialTitle,
                                              controller: materialController,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                : SizedBox(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Column(
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!
                                                  .createTaskPage_realizationDateTitle,
                                              style: const TextStyle(
                                                  fontSize: 16.0),
                                            ),
                                            const SizedBox(height: 10.0),
                                            SizedBox(
                                              width: 148,
                                              child: InkWell(
                                                overlayColor: MaterialStateColor
                                                    .resolveWith((states) =>
                                                        Colors.transparent),
                                                onTap: () async {
                                                  final DateTime? pickedDate =
                                                      await showCustomDatePicker(
                                                          context, startDate!);
                                                  if (pickedDate != null) {
                                                    handleReleasedDateChange(
                                                        pickedDate);
                                                  }
                                                },
                                                child: IgnorePointer(
                                                  child: CustomTextFormField(
                                                    useValidation: false,
                                                    width: 128,
                                                    height: 54,
                                                    fontSize: 12,
                                                    hintText: AppLocalizations
                                                            .of(context)!
                                                        .default_datepicker_hint,
                                                    controller:
                                                        releasedDateController,
                                                    //enabled: false,
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        const SizedBox(height: 10.0),
                                        Column(
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!
                                                  .createTaskPage_longitudeTitle,
                                              style: const TextStyle(
                                                  fontSize: 16.0),
                                            ),
                                            const SizedBox(height: 10.0),
                                            CustomTextFormField(
                                              useValidation: false,
                                              width: 148,
                                              height: 54,
                                              fontSize: 12,
                                              textInputType:
                                                  TextInputType.number,
                                              hintText: AppLocalizations.of(
                                                      context)!
                                                  .createTaskPage_longitudeTitle,
                                              controller: lengthController,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10.0),
                                        Column(
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!
                                                  .createTaskPage_materialTitle,
                                              style: const TextStyle(
                                                  fontSize: 16.0),
                                            ),
                                            const SizedBox(height: 10.0),
                                            CustomTextFormField(
                                              useValidation: false,
                                              width: 148,
                                              height: 54,
                                              fontSize: 12,
                                              hintText: AppLocalizations.of(
                                                      context)!
                                                  .createTaskPage_materialTitle,
                                              controller: materialController,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                            const SizedBox(
                                height: AppConstants.taskColumnSpace),
                            InspectionLocationSelect(
                                selectedItemsProvider: selectedItemsProvider),
                            const SizedBox(
                                height: AppConstants.taskColumnSpace),
                            ElementsSelected(widget: widget),
                            const SizedBox(
                                height: AppConstants.taskColumnSpace),
                            if (widget.detail)
                              Column(
                                children: [
                                  const SizedBox(height: 10.0),
                                  Text(
                                    AppLocalizations.of(context)!
                                        .createTaskPage_observationsTitle,
                                    style: const TextStyle(fontSize: 16.0),
                                  ),
                                  const SizedBox(height: 10.0),
                                  CustomTextFormField(
                                    useValidation: false,
                                    isTextBox: true,
                                    maxLines: 10,
                                    width: widthRow,
                                    height: heightRow,
                                    hintText: AppLocalizations.of(context)!
                                        .default_observationsPlaceholder,
                                    controller: observationsController,
                                  ),
                                  const SizedBox(height: 10.0),
                                  Text(
                                    AppLocalizations.of(context)!
                                        .createTaskPage_conclusionsTitle,
                                    style: const TextStyle(fontSize: 16.0),
                                  ),
                                  const SizedBox(height: 10.0),
                                  CustomTextFormField(
                                    useValidation: false,
                                    isTextBox: true,
                                    maxLines: 10,
                                    width: widthRow,
                                    height: heightRow,
                                    hintText: AppLocalizations.of(context)!
                                        .default_conclusionsPlaceholder,
                                    controller: conclusionsController,
                                  ),
                                ],
                              ),
                            const SizedBox(height: 10.0),
                            Text(
                              AppLocalizations.of(context)!.images_title,
                              style: const TextStyle(fontSize: 16.0),
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              width: widthRow,
                              child: Column(
                                children: [
                                  TaskImageGalleryModal(idTask: widget.idTask!),
                                ],
                              ),
                            ),
                            Text(
                              AppLocalizations.of(context)!.informe_title,
                              style: const TextStyle(fontSize: 16.0),
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              width: widthRow,
                              child: Column(children: [
                                InformeUploadComponent(idTask: widget.idTask!)
                              ]),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Visibility(
                      visible: selectedIndex == 1,
                      child: Container(
                        height: 50.0,
                        margin: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.detail)
                              CustomElevatedButton(
                                messageType: MessageType.error,
                                onPressed: handleCancel,
                                text: AppLocalizations.of(context)!
                                    .buttonCancelLabel,
                              ),
                            const SizedBox(width: 12.0),
                            CustomElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  if (widget.detail) {
                                    handleEditTask();
                                  } else {
                                    // Se quita acción de creación en Programada
                                    if (selectedIndex == 1) {
                                      handleSubmit();
                                    }
                                  }
                                } else {
                                  scrollToTopScrollView();
                                }
                              },
                              text: widget.detail
                                  ? AppLocalizations.of(context)!
                                      .buttonAcceptLabel
                                  : AppLocalizations.of(context)!
                                      .createTaskPage_submitButton,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      });
    });
  }
}
