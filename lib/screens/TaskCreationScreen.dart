import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtau_app_front/models/task_status.dart';
import 'package:gtau_app_front/providers/user_provider.dart';
import 'package:gtau_app_front/widgets/common/box_container.dart';
import 'package:gtau_app_front/widgets/common/customMessageDialog.dart';
import 'package:gtau_app_front/widgets/loading_overlay.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../constants/app_constants.dart';
import '../dto/image_data.dart';
import '../models/task.dart';
import '../providers/selected_items_provider.dart';
import '../providers/task_filters_provider.dart';
import '../utils/boxes.dart';
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
                  //const SizedBox(height: 36.0),
                  Text(
                    widget.detail
                        ? AppLocalizations.of(context)!
                            .createTaskPage_titleOnEdit
                        : AppLocalizations.of(context)!.createTaskPage_title,
                    style: const TextStyle(fontSize: 32.0),
                  ),
                  const SizedBox(height: 20.0),
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
                  //if (selectedIndex == 1)
                  Visibility(
                    visible: selectedIndex == 1 && kIsWeb,
                    child: BoxContainer(
                      width: widthRow * 1.15,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
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
                                  const SizedBox(
                                      width: AppConstants.taskRowSpace),
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
                          const SizedBox(height: 20.0),
                          if (widget.detail) const SizedBox(height: 10.0),
                          if (widget.detail)
                            Text(
                              AppLocalizations.of(context)!
                                  .createTaskPage_realizationDateTitle,
                              style: const TextStyle(fontSize: 24.0),
                            ),
                          Visibility(
                            visible: widget.detail,
                            child: InkWell(
                              onTap: () async {
                                final DateTime? pickedDate =
                                    await showDatePicker(
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
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context)!
                                        .default_datepicker_hint,
                                  ),
                                  controller: releasedDateController,
                                  enabled: false,
                                ),
                              ),
                            ),
                          ),
                          if (widget.detail) const SizedBox(height: 10.0),
                          Visibility(
                            visible: widget.detail,
                            child: MapModal(),
                          ),
                          Visibility(
                            visible: widget.detail,
                            child: Consumer<SelectedItemsProvider>(
                              builder: (context, selectedItemsProvider, child) {
                                final selectedSections = selectedItemsProvider
                                    .selectedPolylines
                                    .toList();
                                final selectedCatchments = selectedItemsProvider
                                    .selectedCatchments
                                    .toList();
                                final selectedRegisters = selectedItemsProvider
                                    .selectedRegisters
                                    .toList();
                                final selectedLots =
                                    selectedItemsProvider.selectedLots.toList();

                                return selectedItemsProvider
                                        .isSomeElementSelected()
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)!
                                                .elementsTitle,
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 10),
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              children: [
                                                Text("tramos: "),
                                                for (var sectionId
                                                    in selectedSections)
                                                  EntityIdContainer(
                                                      id: sectionId.value),
                                                const SizedBox(height: 10),
                                                Text("captaciones: "),
                                                for (var catchmentId
                                                    in selectedCatchments)
                                                  EntityIdContainer(
                                                      id: catchmentId.value),
                                                const SizedBox(height: 10),
                                                Text("registros: "),
                                                for (var registerId
                                                    in selectedRegisters)
                                                  EntityIdContainer(
                                                      id: registerId.value),
                                                const SizedBox(height: 10),
                                                Text("parcelas: "),
                                                for (var lotId in selectedLots)
                                                  EntityIdContainer(
                                                      id: lotId.value),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)!
                                                .elementsTitle,
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      );
                              },
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          // Text(
                          //   AppLocalizations.of(context)!
                          //       .createTaskPage_selectUbicationTitle,
                          //   style: const TextStyle(fontSize: 24.0),
                          // ),
                          // TextFormField(
                          //   decoration: InputDecoration(
                          //     hintText: AppLocalizations.of(context)!
                          //         .default_placeHolderInputText,
                          //     border: const OutlineInputBorder(),
                          //   ),
                          //   controller: locationController,
                          // ),
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

                          const SizedBox(height: 10.0)
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
                                width: widthRow,
                                height: heightrow,
                                hintText: AppLocalizations.of(context)!
                                    .default_descriptionPlaceholder,
                                controller: descriptionController,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20.0),
                          if (widget.detail) const SizedBox(height: 10.0),
                          if (widget.detail)
                            Text(
                              AppLocalizations.of(context)!
                                  .createTaskPage_realizationDateTitle,
                              style: const TextStyle(fontSize: 24.0),
                            ),
                          Visibility(
                            visible: widget.detail,
                            child: InkWell(
                              onTap: () async {
                                final DateTime? pickedDate =
                                    await showDatePicker(
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
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context)!
                                        .default_datepicker_hint,
                                  ),
                                  controller: releasedDateController,
                                  enabled: false,
                                ),
                              ),
                            ),
                          ),
                          if (widget.detail) const SizedBox(height: 10.0),
                          Visibility(
                            visible: widget.detail,
                            child: MapModal(),
                          ),
                          Visibility(
                            visible: widget.detail,
                            child: Consumer<SelectedItemsProvider>(
                              builder: (context, selectedItemsProvider, child) {
                                final selectedSections = selectedItemsProvider
                                    .selectedPolylines
                                    .toList();
                                final selectedCatchments = selectedItemsProvider
                                    .selectedCatchments
                                    .toList();
                                final selectedRegisters = selectedItemsProvider
                                    .selectedRegisters
                                    .toList();
                                final selectedLots =
                                    selectedItemsProvider.selectedLots.toList();

                                return selectedItemsProvider
                                        .isSomeElementSelected()
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)!
                                                .elementsTitle,
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 10),
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              children: [
                                                Text("tramos: "),
                                                for (var sectionId
                                                    in selectedSections)
                                                  EntityIdContainer(
                                                      id: sectionId.value),
                                                const SizedBox(height: 10),
                                                Text("captaciones: "),
                                                for (var catchmentId
                                                    in selectedCatchments)
                                                  EntityIdContainer(
                                                      id: catchmentId.value),
                                                const SizedBox(height: 10),
                                                Text("registros: "),
                                                for (var registerId
                                                    in selectedRegisters)
                                                  EntityIdContainer(
                                                      id: registerId.value),
                                                const SizedBox(height: 10),
                                                Text("parcelas: "),
                                                for (var lotId in selectedLots)
                                                  EntityIdContainer(
                                                      id: lotId.value),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)!
                                                .elementsTitle,
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      );
                              },
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          // Text(
                          //   AppLocalizations.of(context)!
                          //       .createTaskPage_selectUbicationTitle,
                          //   style: const TextStyle(fontSize: 24.0),
                          // ),
                          // TextFormField(
                          //   decoration: InputDecoration(
                          //     hintText: AppLocalizations.of(context)!
                          //         .default_placeHolderInputText,
                          //     border: const OutlineInputBorder(),
                          //   ),
                          //   controller: locationController,
                          // ),
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

                          const SizedBox(height: 10.0)
                        ],
                      ),
                    ),
                  ),
                  if (selectedIndex == 0)
                    Column(
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
                  const SizedBox(height: 10.0),
                  // Text(
                  //   AppLocalizations.of(context)!.default_descriptionTitle,
                  //   style: const TextStyle(fontSize: 24.0),
                  // ),
                  // TextFormField(
                  //   decoration: InputDecoration(
                  //     hintText: AppLocalizations.of(context)!
                  //         .default_descriptionPlaceholder,
                  //     border: const OutlineInputBorder(),
                  //   ),
                  //   controller: descriptionController,
                  // ),
                  if (widget.detail)
                    Column(
                      children: [
                        const SizedBox(height: 10.0),
                        Text(
                          AppLocalizations.of(context)!
                              .createTaskPage_longitudeTitle,
                          style: const TextStyle(fontSize: 24.0),
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
                        Text(
                          AppLocalizations.of(context)!
                              .createTaskPage_materialTitle,
                          style: const TextStyle(fontSize: 24.0),
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
                        Text(
                          AppLocalizations.of(context)!
                              .createTaskPage_observationsTitle,
                          style: const TextStyle(fontSize: 24.0),
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
                        Text(
                          AppLocalizations.of(context)!
                              .createTaskPage_conclusionsTitle,
                          style: const TextStyle(fontSize: 24.0),
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
                  Visibility(
                    visible: widget.detail,
                    child: UserImage(
                        onFileChanged: (imagesFiles) {
                          this.imagesFiles = imagesFiles;
                        },
                        idTask: widget.idTask),
                  ),
                  Visibility(
                    visible: widget.detail,
                    child: ImageGalleryModal(idTask: widget.idTask!),
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
                            child: Text(AppLocalizations.of(context)!
                                .buttonCancelLabel),
                          ),
                        const SizedBox(width: 10.0),
                        CustomElevatedButton(
                          onPressed:
                              widget.detail ? handleEditTask : handleSubmit,
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

class EntityIdContainer extends StatelessWidget {
  const EntityIdContainer({
    super.key,
    required this.id,
  });

  final String id;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(id),
    );
  }
}
