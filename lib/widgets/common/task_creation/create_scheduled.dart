import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtau_app_front/widgets/common/box_container.dart';

import '../../../constants/app_constants.dart';
import '../../../models/task_status.dart';
import '../../../utils/date_utils.dart';
import '../custom_dropdown.dart';
import '../custom_elevated_button.dart';
import '../custom_text_form_field.dart';

class CreateScheduled extends StatefulWidget {
  const CreateScheduled({Key? key}) : super(key: key);

  @override
  State<CreateScheduled> createState() => _CreateScheduledState();
}

class _CreateScheduledState extends State<CreateScheduled> {
  final scheduledNumberController = TextEditingController();
  final addDateController = TextEditingController();
  final endDateController = TextEditingController();
  final numWorkController = TextEditingController();
  final observationsController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String taskStatus = 'PENDING';
  late DateTime? startDate;
  late DateTime? endDate;

  @override
  void initState() {
    super.initState();
    startDate = DateTime.now();
  }

  @override
  void dispose() {
    scheduledNumberController.dispose();
    addDateController.dispose();
    numWorkController.dispose();
    endDateController.dispose();
    observationsController.dispose();
    super.dispose();
  }

  void _handleStartDateChange(DateTime date) {
    setState(() {
      startDate = date;
    });
    addDateController.text = parseDateTimeOnFormat(date);
  }

  void _handleEndDateChange(DateTime date) {
    setState(() {
      endDate = date;
    });
    addDateController.text = parseDateTimeOnFormat(date);
  }

  @override
  Widget build(BuildContext context) {
    double widthRow = 640;

    return Column(children: [
      BoxContainer(
        width: widthRow * 1.15,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                AppLocalizations.of(context)!.createTaskPage_scheduled,
                style: const TextStyle(fontSize: 32.0),
              ),
              Column(
                children: [
                  const SizedBox(height: 24.0),
                  const Text(
                    'Título',
                    style: TextStyle(fontSize: 16.0),
                  ),
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
                                      await showDatePicker(
                                    context: context,
                                    initialDate: startDate!,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (pickedDate != null) {
                                    _handleEndDateChange(pickedDate);
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
                              'Fecha final',
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
                                      await showDatePicker(
                                    context: context,
                                    initialDate: startDate!,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (pickedDate != null) {
                                    _handleStartDateChange(pickedDate);
                                  }
                                },
                                child: IgnorePointer(
                                  child: CustomTextFormField(
                                    useValidation: false,
                                    width: AppConstants.taskRowSpace,
                                    hintText: 'Fecha fin',
                                    controller: endDateController,
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
                  //const SizedBox(height: 8.0),
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
                    //height: heightRow,
                    hintText: AppLocalizations.of(context)!
                        .default_observationsPlaceholder,
                    controller: observationsController,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: AppConstants.taskColumnSpace),
      CustomElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {}
        },
        text: AppLocalizations.of(context)!.buttonAcceptLabel,
      ),
    ]);
  }
}
