import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:gtau_app_front/models/enums/checkbox_state_patologias.dart';
import 'package:gtau_app_front/models/enums/element_type.dart';
import 'package:gtau_app_front/models/scheduled/section_scheduled.dart';
import 'package:gtau_app_front/viewmodels/scheduled_viewmodel.dart';
import 'package:gtau_app_front/widgets/common/custom_textfield.dart';
import 'package:gtau_app_front/widgets/common/scheduled_form_common.dart';
import 'package:gtau_app_front/widgets/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../models/enums/message_type.dart';
import '../../models/scheduled/element_found.dart';
import '../../providers/user_provider.dart';
import '../../utils/common_utils.dart';
import '../../utils/date_utils.dart';
import '../../utils/element_functions.dart';
import '../scheduled_image_gallery_modal.dart';
import 'chip_registered_element.dart';
import 'container_divider.dart';
import 'container_scheduled_info.dart';
import 'customDialog.dart';
import 'customMessageDialog.dart';
import 'custom_dropdown.dart';
import 'custom_elevated_button.dart';
import 'custom_labeled_checkbox.dart';
import 'custom_text_form_field.dart';

class ScheduledFormSection extends StatefulWidget {
  final int sectionId;
  final int scheduledId;
  final Function()? onCancel;
  final Function()? onAccept;

  const ScheduledFormSection(
      {Key? key,
      required this.sectionId,
      required this.scheduledId,
      this.onCancel,
      this.onAccept})
      : super(key: key);

  @override
  State<ScheduledFormSection> createState() => _ScheduledFormSection();
}

class _ScheduledFormSection extends State<ScheduledFormSection> {
  final AutoScrollController _scrollController = AutoScrollController();
  final FocusNode _observationsFocusNode = FocusNode();
  late StreamSubscription<bool> keyboardSubscription;
  late String idSection = 'ID';
  late SectionScheduled sectionScheduled =
      SectionScheduled(inspectioned: false);
  final _typeController = TextEditingController();
  final _catastroController = TextEditingController();
  final _observationsController = TextEditingController();
  final _diamController1 = TextEditingController();
  final _diamController2 = TextEditingController();
  final _longitudeController = TextEditingController();
  final _userNameController = TextEditingController();
  final _longitudeFocusNode = FocusNode();
  final _diamFocusNode1 = FocusNode();
  final _diamFocusNode2 = FocusNode();
  final _typeFocusNode = FocusNode();
  final _userNameFocusNode = FocusNode();
  bool danioCheckboxValue = false;
  bool raizCheckboxValue = false;
  bool upStreamCheckbox = false;
  bool downStreamCheckbox = false;
  bool piedrasOEscombrosCheckboxValue = false;
  String? sedimentLevel = null;
  String? cadastre = null;
  final _catastroDropdownFocusNode = FocusNode();
  List<FocusNode> focusNodes = [];
  late String token;
  late ScheduledViewModel? scheduledViewModel;
  late UserProvider userStateProvider;
  String elementFound = FoundStatusType.Found.toLabel();

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
      _userNameFocusNode
    ];
    keyboardSubscription =
        KeyboardVisibilityController().onChange.listen((bool visible) {
      if (visible) {
        scrollToFocusedList(focusNodes, _scrollController);
      }
    });
    token = context.read<UserProvider>().getToken!;
    scheduledViewModel = context.read<ScheduledViewModel>();
    userStateProvider = Provider.of<UserProvider>(context, listen: false);
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
    SectionScheduled? sectionScheduledResponse =
        await scheduledViewModel?.fetchSectionScheduledById(
            token, widget.scheduledId, widget.sectionId);
    if (sectionScheduledResponse != null) {
      setState(() {
        sectionScheduled = sectionScheduledResponse;
        idSection = sectionScheduledResponse.idTramo.toString();
      });
      _loadInfoFromResponse(sectionScheduledResponse);
    }
  }

  void _loadInfoFromResponse(SectionScheduled sectionScheduled) {
    _diamController1.text = (sectionScheduled.diametro ?? '').toString();
    _diamController2.text = (sectionScheduled.diametro2 ?? '').toString();
    _longitudeController.text = (sectionScheduled.longitud ?? '').toString();
    _typeController.text = sectionScheduled.tipoTra ?? '';
    setState(() {
      elementFound = parseElementFoundLabel(sectionScheduled.notFound ?? false);
    });
    if (sectionScheduled.inspectioned) {
      _userNameController.text = sectionScheduled.username!;
      _observationsController.text = sectionScheduled.observaciones ?? '';
      downStreamCheckbox = sectionScheduled.observacionAguaAbajo ?? false;
      upStreamCheckbox = sectionScheduled.observacionAguaArriba ?? false;
      sedimentLevel = sectionScheduled.nivelSedimentacion ??
          AppLocalizations.of(context)!.form_scheduled_sd;
      cadastre = sectionScheduled.catastro ??
          AppLocalizations.of(context)!.form_scheduled_cadastre_type_empty;
      _loadPathologies(sectionScheduled.patologias ?? []);
    }
  }

  void _loadPathologies(List<String> pathologies) {
    List<CheckboxStatePathology> pathologiesStates =
        parseListPathologies(pathologies);
    setState(() {
      danioCheckboxValue =
          pathologiesStates.contains(CheckboxStatePathology.Danio);
      raizCheckboxValue =
          pathologiesStates.contains(CheckboxStatePathology.Raiz);
      piedrasOEscombrosCheckboxValue =
          pathologiesStates.contains(CheckboxStatePathology.PiedrasOEscombros);
    });
  }

  List<String> pathologiesSelectedToList() {
    List<String> ret = [];
    if (danioCheckboxValue) {
      ret.add(
          parseCheckboxStatePathologyToString(CheckboxStatePathology.Danio));
    }
    if (raizCheckboxValue) {
      ret.add(parseCheckboxStatePathologyToString(CheckboxStatePathology.Raiz));
    }
    if (piedrasOEscombrosCheckboxValue) {
      ret.add(parseCheckboxStatePathologyToString(
          CheckboxStatePathology.PiedrasOEscombros));
    }
    return ret;
  }

  void updateSection() async {
    final Map<String, dynamic> requestBody = {
      "tipoTra": _typeController.text,
      "diametro": _diamController1.text.isNotEmpty
          ? double.parse(_diamController1.text)
          : null,
      "diametro2": _diamController2.text.isNotEmpty
          ? double.parse(_diamController2.text)
          : null,
      "longitud": _longitudeController.text.isNotEmpty
          ? double.parse(_longitudeController.text)
          : null,
      "notFound": isElementNotFound(elementFound) ?? false,
      "nivelSedimentacion": sedimentLevel,
      "observacionAguaArriba": upStreamCheckbox,
      "observacionAguaAbajo": downStreamCheckbox,
      "patologias": pathologiesSelectedToList(),
      "catastro": cadastre,
      "observaciones": _observationsController.text,
      "inspectioned": true,
      "inspectionedDate": getCurrentHour(),
      "username": userStateProvider.userName
    };
    try {
      bool? result = await scheduledViewModel?.updateSectionScheduled(
        token,
        widget.scheduledId,
        widget.sectionId,
        requestBody,
      );
      showMessageOnScreen(result);
    } catch (error) {
      printOnDebug("Error: $error");
      showMessageErrorOnFetch();
    }
  }

  void showMessageErrorOnFetch() async {
    await showCustomMessageDialog(
      context: context,
      onAcceptPressed: () {
        Navigator.of(context).pop();
      },
      customText: AppLocalizations.of(context)!.error_generic_text,
      messageType: DialogMessageType.error,
    );
  }

  void showMessageOnScreen(bool? result) async {
    if (result != null && result) {
      await showCustomMessageDialog(
        context: context,
        messageType: DialogMessageType.success,
        onAcceptPressed: () {
          if (widget.onAccept != null) {
            widget.onAccept!();
          }
          if (!kIsWeb) {
            Navigator.of(context).pop();
          }
        },
      );
    } else {
      await showCustomMessageDialog(
        context: context,
        onAcceptPressed: () {
          Navigator.of(context).pop();
        },
        customText: AppLocalizations.of(context)!.error_generic_text,
        messageType: DialogMessageType.error,
      );
    }
  }

  void showConfirmationDialog() async {
    await showCustomDialog(
      context: context,
      title: AppLocalizations.of(context)!.dialogWarning,
      content: AppLocalizations.of(context)!.dialogContent,
      onDisablePressed: () {
        Navigator.of(context).pop();
      },
      onEnablePressed: () {
        Navigator.of(context).pop();
        updateSection();
      },
      acceptButtonLabel: AppLocalizations.of(context)!.dialogAcceptButton,
      cancelbuttonLabel: AppLocalizations.of(context)!.dialogCancelButton,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ScheduledViewModel>(
        builder: (context, scheduledViewModel, child) {
      return LoadingOverlay(
        isLoading: scheduledViewModel.isLoading,
        child: Column(
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
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
                                      Text(idSection),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            RegistrationChip(
                                isRegistered: sectionScheduled.inspectioned),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsetsDirectional.only(
                            bottom: 8, start: 4, end: 4),
                        child: Divider(color: Colors.grey, thickness: 1),
                      ),
                      Visibility(
                        visible: sectionScheduled.inspectioned,
                        child: ScheduledInspectionDetails(
                          username: sectionScheduled.username ?? '',
                          inspectionedDate: sectionScheduled.inspectionedDate ??
                              DateTime.now(),
                        ),
                      ),
                      ContainerBottomDivider(children: [
                        ScheduledFormTitle(
                            titleText: AppLocalizations.of(context)!
                                .form_scheduled_element_found),
                        CustomDropdown(
                            fontSize: 12,
                            value: elementFound,
                            items: [
                              FoundStatusType.Found.toLabel(),
                              FoundStatusType.NotFound.toLabel()
                            ],
                            onChanged: (str) {
                              setState(() {
                                elementFound = str;
                              });
                            }),
                        const SizedBox(height: 8)
                      ]),
                      if (sectionScheduled.inspectioned)
                        const SizedBox(height: 12),
                      ContainerBottomDivider(children: [
                        ScheduledFormTitle(
                            titleText: AppLocalizations.of(context)!
                                .form_scheduled_cadastre),
                        CustomDropdown(
                            width: 120,
                            fontSize: 12,
                            value: cadastre ??
                                AppLocalizations.of(context)!
                                    .form_scheduled_cadastre_type_empty,
                            items: [
                              AppLocalizations.of(context)!
                                  .form_scheduled_cadastre_type_new,
                              AppLocalizations.of(context)!
                                  .form_scheduled_cadastre_type_adjust,
                              AppLocalizations.of(context)!
                                  .form_scheduled_cadastre_type_empty
                            ],
                            onChanged: (str) {
                              setState(() {
                                cadastre = str;
                              });
                            }),
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
                            titleText: AppLocalizations.of(context)!
                                .form_scheduled_diam1),
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
                            titleText: AppLocalizations.of(context)!
                                .form_scheduled_diam2),
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
                            value: sedimentLevel ??
                                AppLocalizations.of(context)!.form_scheduled_sd,
                            items: [
                              AppLocalizations.of(context)!.form_scheduled_sd,
                              AppLocalizations.of(context)!
                                  .form_scheduled_sediment_level_1,
                              AppLocalizations.of(context)!
                                  .form_scheduled_sediment_level_2,
                              AppLocalizations.of(context)!
                                  .form_scheduled_sediment_level_3
                            ],
                            onChanged: (str) {
                              setState(() {
                                sedimentLevel = str;
                              });
                            }),
                        const SizedBox(height: 8),
                      ]),
                      const SizedBox(height: 12),
                      ContainerBottomDivider(children: [
                        // Niveles de sedimentación - END
                        ScheduledFormTitle(
                            titleText: AppLocalizations.of(context)!
                                .form_scheduled_inspect_from),
                        CustomLabeledCheckbox(
                          initialValue: upStreamCheckbox,
                          label: AppLocalizations.of(context)!
                              .form_scheduled_inspect_from_upstream,
                          onChanged: (value) {
                            setState(() {
                              upStreamCheckbox = value!;
                            });
                          },
                        ),
                        CustomLabeledCheckbox(
                          initialValue: downStreamCheckbox,
                          label: AppLocalizations.of(context)!
                              .form_scheduled_inspect_from_downstream,
                          onChanged: (value) {
                            setState(() {
                              downStreamCheckbox = value!;
                            });
                          },
                        ),
                      ]),
                      const SizedBox(height: 12),
                      // Patologías
                      ContainerBottomDivider(children: [
                        ScheduledFormTitle(
                            titleText: AppLocalizations.of(context)!
                                .form_scheduled_section_pathology),
                        CustomLabeledCheckbox(
                          initialValue: danioCheckboxValue,
                          label: AppLocalizations.of(context)!
                              .form_scheduled_section_pathology_damage,
                          onChanged: (value) {
                            setState(() {
                              danioCheckboxValue = value!;
                            });
                          },
                        ),
                        CustomLabeledCheckbox(
                          initialValue: raizCheckboxValue,
                          label: AppLocalizations.of(context)!
                              .form_scheduled_section_pathology_root,
                          onChanged: (value) {
                            setState(() {
                              raizCheckboxValue = value!;
                            });
                          },
                        ),
                        CustomLabeledCheckbox(
                          initialValue: piedrasOEscombrosCheckboxValue,
                          label: AppLocalizations.of(context)!
                              .form_scheduled_section_pathology_stones,
                          onChanged: (value) {
                            setState(() {
                              piedrasOEscombrosCheckboxValue = value!;
                            });
                          },
                        ),
                      ]),
                      // Patologías - END
                      const SizedBox(height: 10.0),
                      ContainerBottomDivider(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.images_title,
                            style: const TextStyle(fontSize: 16.0),
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                ScheduledImageGalleryModal(
                                    scheduledId: widget.scheduledId,
                                    elementId: widget.sectionId,
                                    elementType: ElementType.section),
                              ],
                            ),
                          ),
                        ],
                      ),
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
                      if (widget.onCancel != null) {
                        widget.onCancel!();
                      }
                      if (!kIsWeb) {
                        Navigator.of(context).pop();
                      }
                    },
                    messageType: MessageType.error,
                    text: AppLocalizations.of(context)!.buttonCancelLabel),
                const SizedBox(width: 16),
                CustomElevatedButton(
                    onPressed: () {
                      showConfirmationDialog();
                    },
                    text: AppLocalizations.of(context)!.buttonAcceptLabel),
              ],
            ),
          ],
        ),
      );
    });
  }
}
