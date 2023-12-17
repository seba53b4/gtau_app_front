import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:gtau_app_front/models/enums/message_type.dart';
import 'package:gtau_app_front/models/scheduled/register_scheduled.dart';
import 'package:gtau_app_front/viewmodels/scheduled_viewmodel.dart';
import 'package:gtau_app_front/widgets/common/container_divider.dart';
import 'package:gtau_app_front/widgets/common/custom_dropdown.dart';
import 'package:gtau_app_front/widgets/common/custom_elevated_button.dart';
import 'package:gtau_app_front/widgets/common/scheduled_form_common.dart';
import 'package:gtau_app_front/widgets/common/top_status_scheduled.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../providers/user_provider.dart';
import '../../utils/date_utils.dart';
import '../../utils/element_functions.dart';
import '../loading_overlay.dart';
import 'chip_registered_element.dart';
import 'container_scheduled_info.dart';
import 'customDialog.dart';
import 'customMessageDialog.dart';
import 'custom_text_form_field.dart';
import 'custom_textfield.dart';

class ScheduledFormRegister extends StatefulWidget {
  final int registerId;
  final int scheduledId;
  final Function()? onCancel;
  final Function()? onAccept;

  const ScheduledFormRegister(
      {Key? key,
      required this.registerId,
      required this.scheduledId,
      this.onCancel,
      this.onAccept})
      : super(key: key);

  @override
  State<ScheduledFormRegister> createState() => _ScheduledFormRegisterState();
}

class _ScheduledFormRegisterState extends State<ScheduledFormRegister> {
  final observationsController = TextEditingController();
  final AutoScrollController _scrollController = AutoScrollController();
  late String idRegister = '';
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
  String? cadastre = null;
  String? paviment = null;
  String? registerStatus = null;
  String? aperture = null;
  Map<String, bool> topStatusChecks = {};
  List<FocusNode> focusNodes = [];
  late RegisterScheduled registerScheduled =
      RegisterScheduled(inspectioned: false, ogcFid: -1);
  late String token;
  late ScheduledViewModel? scheduledViewModel;
  late UserProvider userStateProvider;

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

  void _loadSectionInfo() async {
    RegisterScheduled? registerScheduledResponse =
        await scheduledViewModel?.fetchRegisterScheduledById(
            token, widget.scheduledId, widget.registerId);
    if (registerScheduledResponse != null) {
      setState(() {
        registerScheduled = registerScheduledResponse;
        idRegister = registerScheduledResponse.idRegistro.toString();
      });
      _loadInfoFromResponse(registerScheduledResponse);
    }
  }

  void _loadInfoFromResponse(RegisterScheduled registerScheduled) {
    if (registerScheduled.inspectioned) {
      _typeController.text = registerScheduled.tipoPto ?? '';
      _cotaController.text = registerScheduled.cotaTapa ?? '';
      _depthController.text = registerScheduled.profundidad ?? '';
      aperture = registerScheduled.apertura ??
          AppLocalizations.of(context)!
              .form_scheduled_aperture_type_not_located;
      observationsController.text = registerScheduled.observaciones ?? '';
      registerStatus = registerScheduled.estadoRegistro ??
          AppLocalizations.of(context)!.form_scheduled_no_data;
      paviment = registerScheduled.tipoPavimento ??
          AppLocalizations.of(context)!.form_scheduled_no_data;
      cadastre = registerScheduled.catastro ??
          AppLocalizations.of(context)!.form_scheduled_cadastre_type_empty;
      setState(() {
        topStatusChecks = {};
        topStatusChecks
            .addAll(initialValueTop(registerScheduled.estadoTapa ?? []));
      });
    }
  }

  Map<String, bool> initialValueTop(List<String> labels) {
    return {for (var label in labels) label: true};
  }

  void updateRegister() async {
    final Map<String, dynamic> requestBody = {
      "tipo": _typeController.text,
      "tipoPavimento": paviment,
      "estadoRegistro": registerStatus,
      "cotaTapa": _cotaController.text,
      "profundidad": _depthController.text,
      "apertura": aperture,
      "estadoTapa": topStatusChecks.keys
          .where((key) => topStatusChecks[key] == true)
          .toList(),
      "catastro": cadastre,
      "observaciones": observationsController.text,
      "inspectioned": true,
      "inspectionedDate": getCurrentHour(),
      "username": userStateProvider.userName
    };
    try {
      bool? result = await scheduledViewModel?.updateRegisterScheduled(
        token,
        widget.scheduledId,
        widget.registerId,
        requestBody,
      );

      showMessageOnScreen(result);
    } catch (error) {
      print("Error: $error");
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
        updateRegister();
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
                                  Text(idRegister),
                                ],
                              ),
                            ),
                            RegistrationChip(
                                isRegistered: registerScheduled.inspectioned),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsetsDirectional.only(
                            bottom: 8, start: 4, end: 4),
                        child: Divider(color: Colors.grey, thickness: 1),
                      ),
                      Visibility(
                        visible: registerScheduled.inspectioned,
                        child: ScheduledInspectionDetails(
                          username: registerScheduled.username ?? '',
                          inspectionedDate:
                              registerScheduled.inspectionedDate ??
                                  DateTime.now(),
                        ),
                      ),
                      ContainerBottomDivider(children: [
                        ScheduledFormTitle(
                            titleText: AppLocalizations.of(context)!
                                .form_scheduled_cadastre),
                        CustomDropdown(
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
                            onChanged: (str) {}),
                        const SizedBox(height: 8)
                      ]),
                      const SizedBox(height: 12),
                      ContainerBottomDivider(children: [
                        ScheduledFormTitle(
                            titleText: AppLocalizations.of(context)!
                                .form_scheduled_register_type),
                        CustomTextField(
                          controller: _typeController,
                          width: 98,
                          keyboardType: TextInputType.number,
                          focusNode: _typeDropdownFocusNode,
                          hasError: false,
                        ),
                      ]),
                      const SizedBox(height: 12),
                      // Tipo de pavimiento
                      ContainerBottomDivider(children: [
                        ScheduledFormTitle(
                            titleText: AppLocalizations.of(context)!
                                .form_scheduled_pav_type),
                        const SizedBox(height: 8),
                        CustomDropdown(
                            fontSize: 12,
                            value: paviment ??
                                AppLocalizations.of(context)!
                                    .form_scheduled_no_data,
                            items: [
                              AppLocalizations.of(context)!
                                  .form_scheduled_pav_type_type_1,
                              AppLocalizations.of(context)!
                                  .form_scheduled_pav_type_type_2,
                              AppLocalizations.of(context)!
                                  .form_scheduled_no_data
                            ],
                            onChanged: (str) {
                              setState(() {
                                paviment = str;
                              });
                            }),
                        const SizedBox(height: 8),
                      ]),
                      const SizedBox(height: 12),
                      ContainerBottomDivider(children: [
                        ScheduledFormTitle(
                            titleText: AppLocalizations.of(context)!
                                .form_scheduled_register_status),
                        const SizedBox(height: 8),
                        CustomDropdown(
                            fontSize: 12,
                            value: registerStatus ??
                                AppLocalizations.of(context)!
                                    .form_scheduled_no_data,
                            items: [
                              AppLocalizations.of(context)!
                                  .form_scheduled_register_status_1,
                              AppLocalizations.of(context)!
                                  .form_scheduled_register_status_2,
                              AppLocalizations.of(context)!
                                  .form_scheduled_register_status_3,
                              AppLocalizations.of(context)!
                                  .form_scheduled_no_data
                            ],
                            onChanged: (str) {
                              setState(() {
                                registerStatus = str;
                              });
                            }),
                        const SizedBox(height: 8),
                      ]),
                      const SizedBox(height: 12),
                      ContainerBottomDivider(children: [
                        ScheduledFormTitle(
                            titleText: AppLocalizations.of(context)!
                                .form_scheduled_cota),
                        CustomTextField(
                          controller: _cotaController,
                          width: 98,
                          keyboardType: TextInputType.number,
                          focusNode: _cotaDropdownFocusNode,
                          hasError: false,
                        ),
                      ]),
                      const SizedBox(height: 12),
                      ContainerBottomDivider(children: [
                        ScheduledFormTitle(
                            titleText: AppLocalizations.of(context)!
                                .form_scheduled_depth),
                        CustomTextField(
                          controller: _depthController,
                          width: 98,
                          keyboardType: TextInputType.number,
                          focusNode: _depthDropdownFocusNode,
                          hasError: false,
                        ),
                      ]),
                      const SizedBox(height: 12),
                      ContainerBottomDivider(children: [
                        ScheduledFormTitle(
                            titleText: AppLocalizations.of(context)!
                                .form_scheduled_aperture),
                        const SizedBox(height: 8),
                        CustomDropdown(
                            fontSize: 12,
                            value: aperture ??
                                AppLocalizations.of(context)!
                                    .form_scheduled_aperture_type_not_located,
                            items: [
                              AppLocalizations.of(context)!
                                  .form_scheduled_aperture_type_yes,
                              AppLocalizations.of(context)!
                                  .form_scheduled_aperture_type_no,
                              AppLocalizations.of(context)!
                                  .form_scheduled_aperture_type_not_located,
                            ],
                            onChanged: (str) {
                              setState(() {
                                aperture = str;
                              });
                            }),
                        const SizedBox(height: 8),
                      ]),
                      const SizedBox(height: 12),
                      ContainerBottomDivider(children: [
                        // Estado de la tapa
                        ScheduledFormTitle(
                            titleText: AppLocalizations.of(context)!
                                .form_scheduled_top_status),
                        TopStatusOptions(
                          initialCheckboxStates: topStatusChecks,
                          onChanged: (Map<String, bool> checks) {
                            setState(() {
                              topStatusChecks = checks;
                            });
                          },
                        ),
                      ]),
                      // Estado de la tapa - END
                      const SizedBox(height: 10.0),
                      ScheduledFormTitle(
                          titleText: AppLocalizations.of(context)!
                              .createTaskPage_observationsTitle),
                      //const SizedBox(height: 10.0),
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
