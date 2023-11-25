import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:gtau_app_front/widgets/common/scheduled_form_common.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../models/enums/message_type.dart';
import '../../utils/element_functions.dart';
import 'container_divider.dart';
import 'custom_dropdown.dart';
import 'custom_elevated_button.dart';
import 'custom_labeled_checkbox.dart';
import 'custom_text_form_field.dart';
import 'custom_textfield.dart';

class ScheduledFormCatchment extends StatefulWidget {
  const ScheduledFormCatchment({Key? key}) : super(key: key);

  @override
  State<ScheduledFormCatchment> createState() => _ScheduledFormCatchment();
}

class _ScheduledFormCatchment extends State<ScheduledFormCatchment> {
  final observationsController = TextEditingController();
  final AutoScrollController _scrollController = AutoScrollController();
  final FocusNode _observationsFocusNode = FocusNode();
  late StreamSubscription<bool> keyboardSubscription;
  final _typeController = TextEditingController();
  final _cotaController = TextEditingController();
  final _depthController = TextEditingController();
  final _catastroController = TextEditingController();
  final _cotaDropdownFocusNode = FocusNode();
  final _depthDropdownFocusNode = FocusNode();
  final _typeDropdownFocusNode = FocusNode();
  final _catastroDropdownFocusNode = FocusNode();
  List<FocusNode> focusNodes = [];

  @override
  void initState() {
    super.initState();
    focusNodes = [
      _cotaDropdownFocusNode,
      _depthDropdownFocusNode,
      _observationsFocusNode,
      _typeDropdownFocusNode,
      _catastroDropdownFocusNode,
    ];
    keyboardSubscription =
        KeyboardVisibilityController().onChange.listen((bool visible) {
      if (visible) {
        scrollToFocusedList(focusNodes, _scrollController);
      }
    });
  }

  @override
  void dispose() {
    keyboardSubscription.cancel();
    _observationsFocusNode.dispose();
    _cotaController.dispose();
    _depthController.dispose();
    _typeController.dispose();
    _typeDropdownFocusNode.dispose();
    _cotaDropdownFocusNode.dispose();
    _depthDropdownFocusNode.dispose();
    _catastroController.dispose();
    _catastroDropdownFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Text(AppLocalizations.of(context)!
                                  .form_scheduled_id),
                              const SizedBox(width: 8),
                              const Text('HD123456'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding:
                        EdgeInsetsDirectional.only(bottom: 8, start: 4, end: 4),
                    child: Divider(color: Colors.grey, thickness: 1),
                  ),
                  ContainerBottomDivider(children: [
                    ScheduledFormTitle(
                        titleText: AppLocalizations.of(context)!
                            .form_scheduled_cadastre),
                    CustomDropdown(
                        fontSize: 12,
                        value: AppLocalizations.of(context)!
                            .form_scheduled_cadastre_type_empty,
                        items: [
                          AppLocalizations.of(context)!
                              .form_scheduled_cadastre_type_new,
                          AppLocalizations.of(context)!
                              .form_scheduled_cadastre_type_adjust,
                          AppLocalizations.of(context)!
                              .form_scheduled_cadastre_type_empty
                        ],
                        onChanged: (str) {}),
                    const SizedBox(height: 8)
                  ]),
                  const SizedBox(height: 12),
                  ContainerBottomDivider(children: [
                    ScheduledFormTitle(
                        titleText: AppLocalizations.of(context)!
                            .form_scheduled_catchm_type),
                    CustomTextField(
                      controller: _typeController,
                      width: 98,
                      keyboardType: TextInputType.number,
                      focusNode: _typeDropdownFocusNode,
                      hasError: false,
                    ),
                  ]),
                  const SizedBox(height: 12),
                  ContainerBottomDivider(children: [
                    ScheduledFormTitle(
                        titleText: AppLocalizations.of(context)!
                            .form_scheduled_catchm_conn),
                    const SizedBox(height: 8),
                    CustomDropdown(
                        fontSize: 12,
                        value: AppLocalizations.of(context)!
                            .form_scheduled_no_data,
                        items: [
                          AppLocalizations.of(context)!
                              .form_scheduled_register_status_1,
                          AppLocalizations.of(context)!
                              .form_scheduled_register_status_2,
                          AppLocalizations.of(context)!
                              .form_scheduled_register_status_3,
                          AppLocalizations.of(context)!.form_scheduled_no_data
                        ],
                        onChanged: (str) {}),
                    const SizedBox(height: 8),
                  ]),
                  const SizedBox(height: 12),
                  ContainerBottomDivider(children: [
                    ScheduledFormTitle(
                        titleText: AppLocalizations.of(context)!
                            .form_scheduled_catchm_call_status),
                    const SizedBox(height: 8),
                    CustomDropdown(
                        fontSize: 12,
                        value: AppLocalizations.of(context)!
                            .form_scheduled_no_data,
                        items: [
                          AppLocalizations.of(context)!
                              .form_scheduled_register_status_1,
                          AppLocalizations.of(context)!
                              .form_scheduled_register_status_2,
                          AppLocalizations.of(context)!
                              .form_scheduled_register_status_3,
                          AppLocalizations.of(context)!.form_scheduled_no_data
                        ],
                        onChanged: (str) {}),
                    const SizedBox(height: 8),
                  ]),
                  const SizedBox(height: 12),
                  ContainerBottomDivider(children: [
                    ScheduledFormTitle(
                        titleText: AppLocalizations.of(context)!
                            .form_scheduled_catchm_slab),
                    const SizedBox(height: 8),
                    CustomDropdown(
                        fontSize: 12,
                        value: AppLocalizations.of(context)!
                            .form_scheduled_no_data,
                        items: [
                          AppLocalizations.of(context)!
                              .form_scheduled_register_status_1,
                          AppLocalizations.of(context)!
                              .form_scheduled_register_status_2,
                          AppLocalizations.of(context)!
                              .form_scheduled_register_status_3,
                          AppLocalizations.of(context)!.form_scheduled_no_data
                        ],
                        onChanged: (str) {}),
                    const SizedBox(height: 8),
                  ]),
                  const SizedBox(height: 12),
                  ContainerBottomDivider(children: [
                    ScheduledFormTitle(
                        titleText: AppLocalizations.of(context)!
                            .form_scheduled_catchm_partition),
                    const SizedBox(height: 8),
                    CustomDropdown(
                        fontSize: 12,
                        value: AppLocalizations.of(context)!
                            .form_scheduled_no_data,
                        items: [
                          AppLocalizations.of(context)!
                              .form_scheduled_register_status_1,
                          AppLocalizations.of(context)!
                              .form_scheduled_register_status_2,
                          AppLocalizations.of(context)!
                              .form_scheduled_register_status_3,
                          AppLocalizations.of(context)!.form_scheduled_no_data
                        ],
                        onChanged: (str) {}),
                    const SizedBox(height: 8),
                  ]),
                  ContainerBottomDivider(children: [
                    ScheduledFormTitle(
                        titleText: AppLocalizations.of(context)!
                            .form_scheduled_catchm_deposit),
                    const SizedBox(height: 8),
                    CustomDropdown(
                        fontSize: 12,
                        value: AppLocalizations.of(context)!
                            .form_scheduled_no_data,
                        items: [
                          AppLocalizations.of(context)!
                              .form_scheduled_register_status_1,
                          AppLocalizations.of(context)!
                              .form_scheduled_register_status_2,
                          AppLocalizations.of(context)!
                              .form_scheduled_register_status_3,
                          AppLocalizations.of(context)!.form_scheduled_no_data
                        ],
                        onChanged: (str) {}),
                    const SizedBox(height: 8),
                  ]),
                  const SizedBox(height: 12),
                  ContainerBottomDivider(children: [
                    // Estado de la tapa
                    ScheduledFormTitle(
                        titleText: AppLocalizations.of(context)!
                            .form_scheduled_catchm_top_status_1),
                    CustomLabeledCheckbox(
                      label: AppLocalizations.of(context)!
                          .form_scheduled_top_status_good,
                      onChanged: (value) {},
                    ),
                    CustomLabeledCheckbox(
                      label: AppLocalizations.of(context)!
                          .form_scheduled_top_status_missing,
                      onChanged: (value) {},
                    ),
                    CustomLabeledCheckbox(
                      label: AppLocalizations.of(context)!
                          .form_scheduled_top_status_sunken,
                      onChanged: (value) {},
                    ),
                    CustomLabeledCheckbox(
                      label: AppLocalizations.of(context)!
                          .form_scheduled_top_status_frame,
                      onChanged: (value) {},
                    ),
                    CustomLabeledCheckbox(
                      label: AppLocalizations.of(context)!
                          .form_scheduled_top_status_broken_frame,
                      onChanged: (value) {},
                    ),
                    CustomLabeledCheckbox(
                      label: AppLocalizations.of(context)!
                          .form_scheduled_top_status_provisional,
                      onChanged: (value) {},
                    ),
                    CustomLabeledCheckbox(
                      label: AppLocalizations.of(context)!
                          .form_scheduled_top_status_broken,
                      onChanged: (value) {},
                    ),
                    CustomLabeledCheckbox(
                      label: AppLocalizations.of(context)!
                          .form_scheduled_top_status_welded_sealed,
                      onChanged: (value) {},
                    ),
                  ]),
                  // Estado de la tapa - END
                  const SizedBox(height: 10.0),
                  ContainerBottomDivider(children: [
                    // Estado de la tapa
                    ScheduledFormTitle(
                        titleText: AppLocalizations.of(context)!
                            .form_scheduled_catchm_top_status_2),
                    CustomLabeledCheckbox(
                      label: AppLocalizations.of(context)!
                          .form_scheduled_top_status_good,
                      onChanged: (value) {},
                    ),
                    CustomLabeledCheckbox(
                      label: AppLocalizations.of(context)!
                          .form_scheduled_top_status_missing,
                      onChanged: (value) {},
                    ),
                    CustomLabeledCheckbox(
                      label: AppLocalizations.of(context)!
                          .form_scheduled_top_status_sunken,
                      onChanged: (value) {},
                    ),
                    CustomLabeledCheckbox(
                      label: AppLocalizations.of(context)!
                          .form_scheduled_top_status_frame,
                      onChanged: (value) {},
                    ),
                    CustomLabeledCheckbox(
                      label: AppLocalizations.of(context)!
                          .form_scheduled_top_status_broken_frame,
                      onChanged: (value) {},
                    ),
                    CustomLabeledCheckbox(
                      label: AppLocalizations.of(context)!
                          .form_scheduled_top_status_provisional,
                      onChanged: (value) {},
                    ),
                    CustomLabeledCheckbox(
                      label: AppLocalizations.of(context)!
                          .form_scheduled_top_status_broken,
                      onChanged: (value) {},
                    ),
                    CustomLabeledCheckbox(
                      label: AppLocalizations.of(context)!
                          .form_scheduled_top_status_welded_sealed,
                      onChanged: (value) {},
                    ),
                  ]),
                  // Estado de la tapa - END
                  const SizedBox(height: 10.0),
                  ScheduledFormTitle(
                      titleText: AppLocalizations.of(context)!
                          .createTaskPage_observationsTitle),
                  SizedBox(
                    width: double.infinity,
                    child: CustomTextFormField(
                      focusNode: _observationsFocusNode,
                      useValidation: false,
                      isTextBox: true,
                      maxLines: 10,
                      hintText: AppLocalizations.of(context)!
                          .default_observationsPlaceholder,
                      controller: observationsController,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                messageType: MessageType.error,
                text: AppLocalizations.of(context)!.buttonCancelLabel),
            const SizedBox(width: 16),
            CustomElevatedButton(
                onPressed: () {},
                text: AppLocalizations.of(context)!.buttonAcceptLabel),
          ],
        ),
      ],
    );
  }
}
