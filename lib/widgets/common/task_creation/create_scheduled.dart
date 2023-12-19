import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtau_app_front/models/scheduled/task_scheduled.dart';
import 'package:gtau_app_front/viewmodels/task_list_scheduled_viewmodel.dart';
import 'package:gtau_app_front/widgets/common/box_container.dart';
import 'package:provider/provider.dart';

import '../../../constants/app_constants.dart';
import '../../../models/task_status.dart';
import '../../../providers/user_provider.dart';
import '../../../utils/date_utils.dart';
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
  final scheduledNumberController = TextEditingController();
  final addDateController = TextEditingController();
  final releasedDateController = TextEditingController();
  final numWorkController = TextEditingController();
  final descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late List<Map<String, dynamic>> geometriesFromFile = [];
  late String taskStatus = 'PENDING';
  late DateTime? startDate;
  late DateTime? releasedDate;
  late bool isAdmin;
  late TaskListScheduledViewModel taskListScheduledViewModel;
  late String token;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // Llama a updateTaskListState después de que la construcción del widget haya finalizado.
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
  }

  @override
  void dispose() {
    scheduledNumberController.dispose();
    addDateController.dispose();
    numWorkController.dispose();
    releasedDateController.dispose();
    descriptionController.dispose();
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
  }

  void loadInfoFromTaskScheduledResponse(TaskScheduled? taskScheduled) {
    if (taskScheduled != null) {
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

  Future handleAcceptOnShowDialogCreateTask() async {
    late String addDateUpdated = formattedDateToUpdate(addDateController.text);
    late String endDateUpdated =
        formattedDateToUpdate(releasedDateController.text);

    Map<String, dynamic> body = {
      // Falta el titulo
      "status": taskStatus,
      "description": descriptionController.text,
      "releasedDate": endDateUpdated,
      "addDate": addDateUpdated,
    };

    bool isUpdated =
        await taskListScheduledViewModel.createScheduledTask(token, body);
    if (isUpdated) {
      await showMessageDialog(DialogMessageType.success);
      return true;
    } else {
      await showMessageDialog(DialogMessageType.error);
      return false;
    }
  }

  void handleSubmit() {
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
  }

  Future<void> showMessageDialog(DialogMessageType type) async {
    await showCustomMessageDialog(
        context: context, messageType: type, onAcceptPressed: () {});
  }

  @override
  Widget build(BuildContext context) {
    double widthRow = 640;
    double heightRow = 128;

    return Center(
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
                    controller: scheduledNumberController,
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
                    //height: heightRow,
                    hintText: AppLocalizations.of(context)!
                        .default_descriptionPlaceholder,
                    controller: descriptionController,
                  ),
                  const SizedBox(height: 24.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.scheduled_file_title,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Visibility(
                        visible: isAdmin,
                        child: SizedBox(
                          width: widthRow,
                          child: FileUploadComponent(
                            onFileAdded:
                                (List<Map<String, dynamic>> geometries) {
                              setState(() {
                                geometriesFromFile = geometries;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ],
              ),
              Visibility(
                visible: widget.isEdit,
                child: Column(children: [
                  const Text(
                    'Inspeccionar Zona',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 12),
                  CustomElevatedButton(
                    onPressed: () async {
                      _showMapElement(context);
                    },
                    text: 'Ver mapa',
                  )
                ]),
              )
            ],
          ),
        ),
      ),
      const SizedBox(height: AppConstants.taskColumnSpace),
      Visibility(
        visible: !widget.isEdit,
        child: CustomElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              handleSubmit();
            }
          },
          text: AppLocalizations.of(context)!.buttonAcceptLabel,
        ),
      ),
    ]));
  }
}
