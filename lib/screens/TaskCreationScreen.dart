import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtau_app_front/models/enums/message_type.dart';
import 'package:gtau_app_front/models/task_status.dart';
import 'package:gtau_app_front/providers/user_provider.dart';
import 'package:gtau_app_front/widgets/common/box_container.dart';
import 'package:gtau_app_front/widgets/common/customMessageDialog.dart';
import 'package:gtau_app_front/widgets/loading_overlay.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../constants/app_constants.dart';
import '../constants/theme_constants.dart';
import '../dto/image_data.dart';
import '../models/enums/element_type.dart';
import '../models/task.dart';
import '../providers/selected_items_provider.dart';
import '../providers/task_filters_provider.dart';
import '../utils/boxes.dart';
import '../utils/colorUtils.dart';
import '../utils/date_utils.dart';
import '../utils/imagesbundle.dart';
import '../viewmodels/images_viewmodel.dart';
import '../viewmodels/task_list_viewmodel.dart';
import '../widgets/common/customDialog.dart';
import '../widgets/common/custom_dropdown.dart';
import '../widgets/common/custom_elevated_button.dart';
import '../widgets/common/custom_text_form_field.dart';
import '../widgets/common/custom_toggle_buttons.dart';
import '../widgets/image_gallery_modal.dart';
import '../widgets/map_modal.dart';
import '../widgets/user_image.dart';

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
  int selectedIndex = 1;
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
  final userAssignedController = TextEditingController();
  final lengthController = TextEditingController();
  final materialController = TextEditingController();
  final observationsController = TextEditingController();
  final conclusionsController = TextEditingController();
  final addDateController = TextEditingController();
  final releasedDateController = TextEditingController();

  SelectedItemsProvider? selectedItemsProvider;

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
      userAssigned = notAssigned;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    selectedItemsProvider = context.read<SelectedItemsProvider>();
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
    if (selectedItemsProvider != null) {
      selectedItemsProvider!.reset();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.detail) {
      widget.type == 'inspection' ? selectedIndex = 1 : selectedIndex = 0;
      releasedDate = DateTime.now();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Llama a updateTaskListState después de que la construcción del widget haya finalizado.
        initializeTask();
      });
      Hive.initFlutter().then((value) => null);
    } else {
      startDate = DateTime.now();
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
        setState(() {
          task = responseTask;
        });
      }

      selectedItemsProvider.setSections(task.sections);
      selectedItemsProvider.setCatchments(task.catchments);
      selectedItemsProvider.setRegisters(task.registers);
      selectedItemsProvider.setLots(task.lots);
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
      initStatus = task.status!;
      if (task.releasedDate != null) {
        releasedDate = task.releasedDate!;
        releasedDateController.text = parseDateTimeOnFormat(task.releasedDate!);
      }
      addDateController.text = parseDateTimeOnFormat(task.addDate!);

      return true;
    } catch (error) {
      print(error);
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
    if (Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ImageBundleAdapter());
    }

    boxImages = await Hive.openBox<ImageBundle>('imagesBox');
    final token = Provider.of<UserProvider>(context, listen: false).getToken;

    final taskListViewModel =
        Provider.of<TaskListViewModel>(context, listen: false);

    try {
      final response =
          await taskListViewModel.updateTask(token!, widget.idTask!, body);

      if (response) {
        print('Tarea ha sido actualizada correctamente');
        await showMessageDialog(DialogMessageType.success);
        return true;
      } else {
        print('No se pudieron traer datos');
        await showMessageDialog(DialogMessageType.error);
        return false;
      }
    } catch (error) {
      print(error);
      throw Exception('Error al obtener los datos');
    }
  }

  Future<void> showMessageDialog(DialogMessageType type) async {
    await showCustomMessageDialog(
        context: context, messageType: type, onAcceptPressed: () {});
  }

  Future<void> initializeTask() async {
    await _fetchTask();
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
          resetSelectionOnMap();
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
    final selectedSections =
        context.read<SelectedItemsProvider>().selectedPolylines;
    final List<String> listSelectedSections =
        selectedSections.map((polylineId) => polylineId.value).toList();

    final selectedCatchments =
        context.read<SelectedItemsProvider>().selectedCatchments;
    final List<String> listSelectedCatchments =
        selectedCatchments.map((circleId) => circleId.value).toList();

    final selectedRegisters =
        context.read<SelectedItemsProvider>().selectedRegisters;
    final List<String> listSelectedRegisters =
        selectedRegisters.map((circleId) => circleId.value).toList();

    final selectedLots = context.read<SelectedItemsProvider>().selectedLots;
    final List<String> listSelectedLots =
        selectedLots.map((polylineId) => polylineId.value).toList();

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
      "tramos": listSelectedSections,
      "captaciones": listSelectedCatchments,
      "registros": listSelectedRegisters,
      "parcelas": listSelectedLots
    };
    return requestBody;
  }

  Map<String, dynamic> createBodyToUpdate() {
    late String addDateUpdated = formattedDateToUpdate(addDateController.text);
    late String? releasedDateSelected = releasedDateController.text.isNotEmpty
        ? formattedDateToUpdate(releasedDateController.text)
        : null;
    final selectedSections =
        context.read<SelectedItemsProvider>().selectedPolylines;
    final List<String> listSelectedSections =
        selectedSections.map((polylineId) => polylineId.value).toList();
    final selectedCatchments =
        context.read<SelectedItemsProvider>().selectedCatchments;
    final List<String> listSelectedCatchments =
        selectedCatchments.map((circleId) => circleId.value).toList();
    final selectedRegisters =
        context.read<SelectedItemsProvider>().selectedRegisters;
    final List<String> listSelectedRegisters =
        selectedRegisters.map((circleId) => circleId.value).toList();
    final selectedLots = context.read<SelectedItemsProvider>().selectedLots;
    final List<String> listSelectedLots =
        selectedLots.map((polylineId) => polylineId.value).toList();

    final Map<String, dynamic> requestBody = {
      "status": taskStatus,
      "inspectionType": task.inspectionType,
      "workNumber": numWorkController.text,
      "addDate": addDateUpdated,
      "applicant": applicantController.text,
      "location": locationController.text,
      "description": descriptionController.text,
      "releasedDate": releasedDateSelected,
      "user": userAssignedController.text,
      "length": lengthController.text,
      "material": materialController.text,
      "observations": observationsController.text,
      "conclusions": conclusionsController.text,
      "tramos": listSelectedSections,
      "captaciones": listSelectedCatchments,
      "registros": listSelectedRegisters,
      "parcelas": listSelectedLots,
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
          print(error);
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
    await updateTaskList();
  }

  Future updateTaskList() async {
    final userName =
        Provider.of<TaskFilterProvider>(context, listen: false).userNameFilter;
    final taskListViewModel =
        Provider.of<TaskListViewModel>(context, listen: false);
    await taskListViewModel.initializeTasks(context, initStatus, userName);
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
        resetSelectionOnMap();
        Navigator.of(context).pop();
      },
      acceptButtonLabel: AppLocalizations.of(context)!.dialogAcceptButton,
      cancelbuttonLabel: AppLocalizations.of(context)!.dialogCancelButton,
    );
  }

  void resetSelectionOnMap() {
    final selectedItemsProvider = context.read<SelectedItemsProvider>();
    selectedItemsProvider.reset();
  }

  void handleCancel() {
    resetSelectionOnMap();
    Navigator.of(context).pop();
  }

  List<ImageDataDTO>? imagesFiles = null;

  @override
  Widget build(BuildContext context) {
    double widthRow = 640;
    double heightrow = 128;

    return Consumer<TaskListViewModel>(
        builder: (context, taskListViewModel, child) {
      return LoadingOverlay(
        isLoading: taskListViewModel.isLoading,
        child: Scaffold(
          body: SingleChildScrollView(
            child: Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
              child: Column(
                children: [
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
                    child: BoxContainer(
                      width: widthRow * 1.15,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.taskInformationTitle,
                            style: const TextStyle(fontSize: 32.0),
                          ),
                          const SizedBox(height: 24.0),
                          // Primera fila
                          SizedBox(
                            height: heightrow,
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
                                            .createTaskPage_numberWorkTitle,
                                        style: const TextStyle(fontSize: 16.0),
                                      ),
                                      const SizedBox(
                                          height: AppConstants.taskColumnSpace),
                                      CustomTextFormField(
                                        hintText: AppLocalizations.of(context)!
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
                                            style:
                                                const TextStyle(fontSize: 16.0),
                                          ),
                                          const SizedBox(height: 12.0),
                                          CustomDropdown(
                                            value: userAssigned,
                                            items: const [
                                              notAssigned,
                                              'gtau-oper',
                                              'gtau-admin'
                                            ],
                                            onChanged: (String? value) {
                                              setState(() {
                                                userAssigned = value!;
                                              });
                                            },
                                          ),
                                          const SizedBox(
                                              height:
                                                  AppConstants.taskColumnSpace),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Column(children: [
                                    Text(
                                      AppLocalizations.of(context)!
                                          .editTaskPage_statusTitle,
                                      style: const TextStyle(fontSize: 16.0),
                                    ),
                                    const SizedBox(height: 12.0),
                                    CustomDropdown(
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
                                        height: AppConstants.taskColumnSpace),
                                  ]),
                                ]),
                          ),
                          // Segunda fila
                          SizedBox(
                            height: heightrow,
                            width: widthRow,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!
                                          .createTaskPage_startDateTitle,
                                      style: const TextStyle(fontSize: 16.0),
                                    ),
                                    const SizedBox(height: 12.0),
                                    SizedBox(
                                      width: AppConstants.textFieldWidth,
                                      child: InkWell(
                                        overlayColor:
                                            MaterialStateColor.resolveWith(
                                                (states) => Colors.transparent),
                                        onTap: () async {
                                          final DateTime? pickedDate =
                                              await showDatePicker(
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
                                          child: CustomTextFormField(
                                            width: AppConstants.taskRowSpace,
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
                                      style: const TextStyle(fontSize: 16.0),
                                    ),
                                    const SizedBox(height: 12.0),
                                    CustomTextFormField(
                                      width: AppConstants.textFieldWidth * 2 +
                                          AppConstants.taskRowSpace,
                                      hintText: AppLocalizations.of(context)!
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
                                    .createTaskPage_selectUbicationTitle,
                                style: const TextStyle(fontSize: 16.0),
                              ),
                              const SizedBox(height: 12.0),
                              CustomTextFormField(
                                width: widthRow,
                                hintText: AppLocalizations.of(context)!
                                    .createTaskPage_selectUbicationplaceholder,
                                controller: locationController,
                              ),
                              const SizedBox(width: AppConstants.taskRowSpace),
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
                                height: heightrow,
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
                  Visibility(
                    visible: selectedIndex == 1 && !kIsWeb,
                    child: BoxContainer(
                      width: widthRow * 1.15,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.taskInformationTitle,
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
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!
                                            .createTaskPage_numberWorkTitle,
                                        style: const TextStyle(fontSize: 12.0),
                                      ),
                                      const SizedBox(
                                          height: AppConstants.taskColumnSpace),
                                      CustomTextFormField(
                                        width: 148,
                                        height: 54,
                                        fontSize: 12,
                                        hintText: AppLocalizations.of(context)!
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
                                      style: const TextStyle(fontSize: 12.0),
                                    ),
                                    const SizedBox(height: 12.0),
                                    CustomDropdown(
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
                          // Segunda fila
                          SizedBox(
                              height: 100,
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
                                        style: const TextStyle(fontSize: 12.0),
                                      ),
                                      const SizedBox(height: 12.0),
                                      SizedBox(
                                        width: 148,
                                        child: InkWell(
                                          overlayColor:
                                              MaterialStateColor.resolveWith(
                                                  (states) =>
                                                      Colors.transparent),
                                          onTap: () async {
                                            final DateTime? pickedDate =
                                                await showDatePicker(
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
                                        style: const TextStyle(fontSize: 12.0),
                                      ),
                                      const SizedBox(height: 12.0),
                                      CustomDropdown(
                                        width: 148,
                                        //height: 54,
                                        fontSize: 12,
                                        value: userAssigned,
                                        items: const [
                                          notAssigned,
                                          'gtau-oper',
                                          'gtau-admin'
                                        ],
                                        onChanged: (String? value) {
                                          setState(() {
                                            userAssigned = value!;
                                          });
                                        },
                                      ),
                                      const SizedBox(
                                          width: AppConstants.taskColumnSpace),
                                    ],
                                  ),
                                ],
                              )),
                          //const SizedBox(height: 20.0),
                          // Tercera columna
                          SizedBox(
                            height: 100,
                            width: widthRow,
                            child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!
                                            .createTaskPage_solicitantTitle,
                                        style: const TextStyle(fontSize: 14.0),
                                      ),
                                      const SizedBox(height: 12.0),
                                      CustomTextFormField(
                                        width: widthRow + 24,
                                        height: 54,
                                        fontSize: 12,
                                        hintText: AppLocalizations.of(context)!
                                            .createTaskPage_solicitantPlaceholder,
                                        controller: applicantController,
                                      ),
                                    ],
                                  )
                                ]),
                          ),
                          // Cuarta columna
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppLocalizations.of(context)!
                                    .createTaskPage_selectUbicationTitle,
                                style: const TextStyle(fontSize: 14.0),
                              ),
                              const SizedBox(height: 12.0),
                              CustomTextFormField(
                                width: widthRow + 24,
                                height: 54,
                                fontSize: 12,
                                hintText: AppLocalizations.of(context)!
                                    .createTaskPage_selectUbicationplaceholder,
                                controller: locationController,
                              ),
                              const SizedBox(height: 12.0),
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
                                height: heightrow,
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
                  Visibility(
                    visible: selectedIndex == 0,
                    child: Column(
                      children: [
                        Text(
                          AppLocalizations.of(context)!
                              .createTaskPage_scheduled,
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
                  ),
                  Visibility(
                    visible: widget.detail,
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
                                            style:
                                                const TextStyle(fontSize: 16.0),
                                          ),
                                          const SizedBox(height: 10.0),
                                          SizedBox(
                                            width: AppConstants.textFieldWidth,
                                            child: InkWell(
                                              overlayColor: MaterialStateColor
                                                  .resolveWith((states) =>
                                                      Colors.transparent),
                                              onTap: () async {
                                                final DateTime? pickedDate =
                                                    await showDatePicker(
                                                  context: context,
                                                  initialDate: releasedDate!,
                                                  firstDate: DateTime(2000),
                                                  lastDate: DateTime(2100),
                                                );
                                                if (pickedDate != null) {
                                                  handleReleasedDateChange(
                                                      pickedDate);
                                                }
                                              },
                                              child: IgnorePointer(
                                                child: CustomTextFormField(
                                                  width: AppConstants
                                                      .textFieldWidth,
                                                  hintText: AppLocalizations.of(
                                                          context)!
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
                                            style:
                                                const TextStyle(fontSize: 16.0),
                                          ),
                                          const SizedBox(height: 10.0),
                                          CustomTextFormField(
                                            width: AppConstants.textFieldWidth,
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
                                            style:
                                                const TextStyle(fontSize: 16.0),
                                          ),
                                          const SizedBox(height: 10.0),
                                          CustomTextFormField(
                                            width: AppConstants.textFieldWidth,
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
                                            style:
                                                const TextStyle(fontSize: 16.0),
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
                                                    await showDatePicker(
                                                  context: context,
                                                  initialDate: releasedDate!,
                                                  firstDate: DateTime(2000),
                                                  lastDate: DateTime(2100),
                                                );
                                                if (pickedDate != null) {
                                                  handleReleasedDateChange(
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
                                            style:
                                                const TextStyle(fontSize: 16.0),
                                          ),
                                          const SizedBox(height: 10.0),
                                          CustomTextFormField(
                                            width: 148,
                                            height: 54,
                                            fontSize: 12,
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
                                            style:
                                                const TextStyle(fontSize: 16.0),
                                          ),
                                          const SizedBox(height: 10.0),
                                          CustomTextFormField(
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
                          const SizedBox(height: AppConstants.taskColumnSpace),

                          // Elementos seleccionados
                          ElementsSelected(widget: widget),
                          const SizedBox(height: 10.0),
                          // Button elementos a seleccionar
                          const MapModal(),
                          const SizedBox(height: 10.0),
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
                                  isTextBox: true,
                                  maxLines: 10,
                                  width: widthRow,
                                  height: heightrow,
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
                                  isTextBox: true,
                                  maxLines: 10,
                                  width: widthRow,
                                  height: heightrow,
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
                                  UserImage(
                                      onFileChanged: (imagesFiles) {
                                        this.imagesFiles = imagesFiles;
                                      },
                                      idTask: widget.idTask),
                                  ImageGalleryModal(idTask: widget.idTask!),
                                ],
                              ))
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 50.0,
                    margin: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.detail)
                          CustomElevatedButton(
                            messageType: MessageType.error,
                            onPressed: handleCancel,
                            text:
                                AppLocalizations.of(context)!.buttonCancelLabel,
                          ),
                        const SizedBox(width: 12.0),
                        CustomElevatedButton(
                          onPressed: () {
                            if (widget.detail) {
                              handleEditTask();
                            } else {
                              // Se quita acción de creación en Programada
                              if (selectedIndex == 1) {
                                handleSubmit();
                              }
                            }
                          },
                          text: widget.detail
                              ? AppLocalizations.of(context)!.buttonAcceptLabel
                              : AppLocalizations.of(context)!
                                  .createTaskPage_submitButton,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

class ElementsSelected extends StatelessWidget {
  const ElementsSelected({
    super.key,
    required this.widget,
  });

  final TaskCreationScreen widget;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.detail,
      child: Consumer<SelectedItemsProvider>(
        builder: (context, selectedItemsProvider, child) {
          final elementsList = <EntityIdContainer>[];

          elementsList
              .addAll(selectedItemsProvider.selectedPolylines.map((element) {
            return EntityIdContainer(
              id: element.value,
              elementType: ElementType.section,
            );
          }));

          elementsList
              .addAll(selectedItemsProvider.selectedCatchments.map((element) {
            return EntityIdContainer(
              id: element.value,
              elementType: ElementType.catchment,
            );
          }));

          elementsList
              .addAll(selectedItemsProvider.selectedRegisters.map((element) {
            return EntityIdContainer(
              id: element.value,
              elementType: ElementType.register,
            );
          }));

          elementsList.addAll(selectedItemsProvider.selectedLots.map((element) {
            return EntityIdContainer(
              id: element.value,
              elementType: ElementType.lot,
            );
          }));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)!.elementsTitle,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              elementsList.isNotEmpty
                  ? Container(
                      padding: const EdgeInsets.all(8),
                      //color: Colors.grey,
                      decoration: BoxDecoration(
                        color: softGrey,
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      child: Wrap(
                        spacing: 15.0,
                        runSpacing: 15.0,
                        children: elementsList,
                      ),
                    )
                  : const Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 12),
                        Text(
                          "No hay elementos registrados",
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ],
                    ),
              const SizedBox(height: 12),
            ],
          );
        },
      ),
    );
  }
}

class EntityIdContainer extends StatelessWidget {
  const EntityIdContainer({
    Key? key,
    required this.id,
    required this.elementType,
  }) : super(key: key);

  final String id;
  final ElementType elementType;

  @override
  Widget build(BuildContext context) {
    final initials = elementType.type;

    return Chip(
      backgroundColor: lightBackground,
      avatar: CircleAvatar(
        backgroundColor: getElementDefaultColor(elementType),
        child: Text(
          initials,
          style: TextStyle(color: Colors.white),
        ),
      ),
      label: Text(id),
    );
  }
}
