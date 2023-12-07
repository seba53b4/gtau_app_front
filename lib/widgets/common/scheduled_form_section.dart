import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:gtau_app_front/models/scheduled/section_scheduled.dart';
import 'package:gtau_app_front/viewmodels/scheduled_viewmodel.dart';
import 'package:gtau_app_front/widgets/common/custom_textfield.dart';
import 'package:gtau_app_front/widgets/common/scheduled_form_common.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../models/enums/message_type.dart';
import '../../providers/user_provider.dart';
import '../../utils/element_functions.dart';
import 'container_divider.dart';
import 'custom_dropdown.dart';
import 'custom_elevated_button.dart';
import 'custom_labeled_checkbox.dart';
import 'custom_text_form_field.dart';

class ScheduledFormSection extends StatefulWidget {
  final int sectionId;
  final int scheduledId;

  const ScheduledFormSection(
      {Key? key, required this.sectionId, required this.scheduledId})
      : super(key: key);

  @override
  State<ScheduledFormSection> createState() => _ScheduledFormSection();
}

class _ScheduledFormSection extends State<ScheduledFormSection> {
  final AutoScrollController _scrollController = AutoScrollController();
  final FocusNode _observationsFocusNode = FocusNode();
  late StreamSubscription<bool> keyboardSubscription;
  late String idSection = 'ID';
  final _typeController = TextEditingController();
  final _catastroController = TextEditingController();
  final _observationsController = TextEditingController();
  final _diamController1 = TextEditingController();
  final _diamController2 = TextEditingController();
  final _longitudeController = TextEditingController();
  final _longitudeFocusNode = FocusNode();
  final _diamFocusNode1 = FocusNode();
  final _diamFocusNode2 = FocusNode();
  final _typeFocusNode = FocusNode();
  final _catastroDropdownFocusNode = FocusNode();
  List<FocusNode> focusNodes = [];
  late String token;
  late ScheduledViewModel? scheduledViewModel;

  @override
  void initState() {
    super.initState();
    focusNodes = [
      _diamFocusNode1,
      _diamFocusNode2,
      _observationsFocusNode,
      _typeFocusNode,
      _longitudeFocusNode,
      _catastroDropdownFocusNode,
    ];
    keyboardSubscription =
        KeyboardVisibilityController().onChange.listen((bool visible) {
      if (visible) {
        scrollToFocusedList(focusNodes, _scrollController);
      }
    });
    token = context.read<UserProvider>().getToken!;
    scheduledViewModel = context.read<ScheduledViewModel>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSectionInfo();
  }

  @override
  void dispose() {
    keyboardSubscription.cancel();
    _observationsFocusNode.dispose();
    _longitudeFocusNode.dispose();
    _diamFocusNode1.dispose();
    _diamController1.dispose();
    _diamFocusNode2.dispose();
    _diamController2.dispose();
    _typeController.dispose();
    _typeFocusNode.dispose();
    _longitudeController.dispose();
    _catastroController.dispose();
    _catastroDropdownFocusNode.dispose();
    super.dispose();
  }

  void _loadSectionInfo() async {
    SectionScheduled? sectionScheduled =
        await scheduledViewModel?.fetchSectionScheduledById(
            token, widget.scheduledId, widget.sectionId);
    if (sectionScheduled != null) {
      setState(() {
        idSection = sectionScheduled.idTramo.toString();
      });
      if (sectionScheduled.inspectioned) {
        // si fue ya inspeccionado se carga la data sino se deja como está.
        _catastroController.text = sectionScheduled.catastro ??
            AppLocalizations.of(context)!.form_scheduled_cadastre_type_empty;
      }
    }
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
                              Text(idSection ?? 'ID'),
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
                            .form_scheduled_section_type),
                    CustomTextField(
                      controller: _typeController,
                      width: 98,
                      keyboardType: TextInputType.number,
                      focusNode: _typeFocusNode,
                      hasError: false,
                    ),
                  ]),
                  const SizedBox(height: 12),
                  // Diámentro (m)
                  ContainerBottomDivider(children: [
                    ScheduledFormTitle(
                        titleText:
                            AppLocalizations.of(context)!.form_scheduled_diam1),
                    CustomTextField(
                      controller: _diamController1,
                      focusNode: _diamFocusNode1,
                      width: 98,
                      keyboardType: TextInputType.number,
                      hasError: false,
                    ),
                  ]),
                  const SizedBox(height: 12),
                  // Diámentro (m)
                  ContainerBottomDivider(children: [
                    ScheduledFormTitle(
                        titleText:
                            AppLocalizations.of(context)!.form_scheduled_diam2),
                    CustomTextField(
                      controller: _diamController2,
                      focusNode: _diamFocusNode2,
                      width: 98,
                      keyboardType: TextInputType.number,
                      hasError: false,
                    ),
                  ]),
                  const SizedBox(height: 12),
                  ContainerBottomDivider(children: [
                    ScheduledFormTitle(
                        titleText: AppLocalizations.of(context)!
                            .form_scheduled_longitude),
                    CustomTextField(
                      controller: _longitudeController,
                      width: 98,
                      focusNode: _longitudeFocusNode,
                      keyboardType: TextInputType.number,
                      hasError: false,
                    ),
                  ]),
                  const SizedBox(height: 12),
                  // Diámentro (m) - END
                  ContainerBottomDivider(children: [
                    ScheduledFormTitle(
                        titleText: AppLocalizations.of(context)!
                            .form_scheduled_sediment_level),
                    CustomDropdown(
                        fontSize: 12,
                        width: 110,
                        value: AppLocalizations.of(context)!.form_scheduled_sd,
                        items: [
                          AppLocalizations.of(context)!.form_scheduled_sd,
                          AppLocalizations.of(context)!
                              .form_scheduled_sediment_level_1,
                          AppLocalizations.of(context)!
                              .form_scheduled_sediment_level_2,
                          AppLocalizations.of(context)!
                              .form_scheduled_sediment_level_3
                        ],
                        onChanged: (str) {}),
                    const SizedBox(height: 8),
                  ]),
                  const SizedBox(height: 12),
                  ContainerBottomDivider(children: [
                    // Niveles de sedimentación - END
                    ScheduledFormTitle(
                        titleText: AppLocalizations.of(context)!
                            .form_scheduled_inspect_from),
                    CustomLabeledCheckbox(
                      label: AppLocalizations.of(context)!
                          .form_scheduled_inspect_from_upstream,
                      onChanged: (value) {},
                    ),
                    CustomLabeledCheckbox(
                      label: AppLocalizations.of(context)!
                          .form_scheduled_inspect_from_downstream,
                      onChanged: (value) {},
                    ),
                  ]),
                  const SizedBox(height: 12),
                  // Patologías
                  ContainerBottomDivider(children: [
                    ScheduledFormTitle(
                        titleText: AppLocalizations.of(context)!
                            .form_scheduled_section_pathology),
                    CustomLabeledCheckbox(
                      label: AppLocalizations.of(context)!
                          .form_scheduled_section_pathology_damage,
                      onChanged: (value) {},
                    ),
                    CustomLabeledCheckbox(
                      label: AppLocalizations.of(context)!
                          .form_scheduled_section_pathology_root,
                      onChanged: (value) {},
                    ),
                    CustomLabeledCheckbox(
                      label: AppLocalizations.of(context)!
                          .form_scheduled_section_pathology_stones,
                      onChanged: (value) {},
                    ),
                  ]),
                  // Patologías - END
                  const SizedBox(height: 10.0),
                  ScheduledFormTitle(
                      titleText: AppLocalizations.of(context)!
                          .createTaskPage_observationsTitle),
                  //const SizedBox(height: 10.0),
                  SizedBox(
                    width: double.infinity,
                    child: CustomTextFormField(
                      focusNode: _observationsFocusNode,
                      onTap: () {},
                      useValidation: false,
                      isTextBox: true,
                      maxLines: 10,
                      hintText: AppLocalizations.of(context)!
                          .default_observationsPlaceholder,
                      controller: _observationsController,
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
