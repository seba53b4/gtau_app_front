import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:gtau_app_front/models/scheduled/catchment_scheduled.dart';
import 'package:gtau_app_front/widgets/common/scheduled_form_common.dart';
import 'package:gtau_app_front/widgets/common/top_status_scheduled.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../models/enums/message_type.dart';
import '../../providers/user_provider.dart';
import '../../utils/date_utils.dart';
import '../../utils/element_functions.dart';
import '../../viewmodels/scheduled_viewmodel.dart';
import '../loading_overlay.dart';
import 'chip_registered_element.dart';
import 'container_divider.dart';
import 'container_scheduled_info.dart';
import 'customDialog.dart';
import 'customMessageDialog.dart';
import 'custom_dropdown.dart';
import 'custom_elevated_button.dart';
import 'custom_text_form_field.dart';
import 'custom_textfield.dart';

class ScheduledFormCatchment extends StatefulWidget {
  final int catchmentId;
  final int scheduledId;
  final Function()? onCancel;
  final Function()? onAccept;

  const ScheduledFormCatchment({
    Key? key,
    required this.catchmentId,
    required this.scheduledId,
    this.onCancel,
    this.onAccept,
  }) : super(key: key);

  @override
  State<ScheduledFormCatchment> createState() => _ScheduledFormCatchment();
}

class _ScheduledFormCatchment extends State<ScheduledFormCatchment> {
  final observationsController = TextEditingController();
  final AutoScrollController _scrollController = AutoScrollController();
  final FocusNode _observationsFocusNode = FocusNode();
  late String idCatchment = '';
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
  late CatchmentScheduled catchmentScheduled =
      CatchmentScheduled(inspectioned: false, ogcFid: -1);
  late String token;
  late ScheduledViewModel? scheduledViewModel;
  late UserProvider userStateProvider;
  Map<String, bool> topStatusChecks_1 = {};
  Map<String, bool> topStatusChecks_2 = {};
  String? cadastre = null;
  String? catchmentConn = null;
  String? catchmentCallStatus = null;
  String? catchmentSlab = null;
  String? catchmentPartition = null;
  String? catchmentDeposit = null;

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
    CatchmentScheduled? catchmentScheduledResponse =
        await scheduledViewModel?.fetchCatchmentScheduledById(
            token, widget.scheduledId, widget.catchmentId);
    if (catchmentScheduledResponse != null) {
      setState(() {
        catchmentScheduled = catchmentScheduledResponse;
        idCatchment = catchmentScheduledResponse.idCaptacion.toString();
      });
      _loadInfoFromResponse(catchmentScheduledResponse);
    }
  }

  void _loadInfoFromResponse(CatchmentScheduled catchmentScheduled) {
    if (catchmentScheduled.inspectioned) {
      setState(() {
        cadastre = catchmentScheduled.catastro ??
            AppLocalizations.of(context)!.form_scheduled_cadastre_type_empty;
        _typeController.text = catchmentScheduled.tipo ?? '';
        catchmentConn = catchmentScheduled.estadoConexion ??
            AppLocalizations.of(context)!.form_scheduled_no_data;
        catchmentCallStatus = catchmentScheduled.estadoLlamada ??
            AppLocalizations.of(context)!.form_scheduled_no_data;
        catchmentSlab = catchmentScheduled.estadoLosa ??
            AppLocalizations.of(context)!.form_scheduled_no_data;
        catchmentPartition = catchmentScheduled.estadoTabique ??
            AppLocalizations.of(context)!.form_scheduled_no_data;
        catchmentDeposit = catchmentScheduled.estadoDeposito ??
            AppLocalizations.of(context)!.form_scheduled_no_data;
        observationsController.text = catchmentScheduled.observaciones ?? '';

        topStatusChecks_1 = {};
        topStatusChecks_1
            .addAll(initialValueTop(catchmentScheduled.tapa1 ?? []));
        topStatusChecks_2 = {};
        topStatusChecks_2
            .addAll(initialValueTop(catchmentScheduled.tapa2 ?? []));
      });
    }
  }

  Map<String, bool> initialValueTop(List<String> labels) {
    return {for (var label in labels) label: true};
  }

  void updateCatchment() async {
    final Map<String, dynamic> requestBody = {
      "tipo": _typeController.text,
      "catastro": cadastre,
      "estadoConexion": catchmentConn,
      "estadoLlamada": catchmentCallStatus,
      "estadoLosa": catchmentSlab,
      "estadoTabique": catchmentPartition,
      "estadoDeposito": catchmentDeposit,
      "tapa1": topStatusChecks_1.keys
          .where((key) => topStatusChecks_1[key] == true)
          .toList(),
      "tapa2": topStatusChecks_2.keys
          .where((key) => topStatusChecks_2[key] == true)
          .toList(),
      "observaciones": observationsController.text,
      "inspectioned": true,
      "inspectionedDate": getCurrentHour(),
      "username": userStateProvider.userName
    };
    try {
      bool? result = await scheduledViewModel?.updateCatchmentScheduled(
        token,
        widget.scheduledId,
        widget.catchmentId,
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
        updateCatchment();
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
                                  Text(idCatchment),
                                ],
                              ),
                            ),
                            RegistrationChip(
                                isRegistered: catchmentScheduled.inspectioned),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsetsDirectional.only(
                            bottom: 8, start: 4, end: 4),
                        child: Divider(color: Colors.grey, thickness: 1),
                      ),
                      Visibility(
                        visible: catchmentScheduled.inspectioned,
                        child: ScheduledInspectionDetails(
                          username: catchmentScheduled.username ?? '',
                          inspectionedDate:
                              catchmentScheduled.inspectionedDate ??
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
                            value: catchmentConn ??
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
                                catchmentConn = str;
                              });
                            }),
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
                            value: catchmentCallStatus ??
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
                                catchmentCallStatus = str;
                              });
                            }),
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
                            value: catchmentSlab ??
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
                                catchmentSlab = str;
                              });
                            }),
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
                            value: catchmentPartition ??
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
                                catchmentPartition = str;
                              });
                            }),
                        const SizedBox(height: 8),
                      ]),
                      ContainerBottomDivider(children: [
                        ScheduledFormTitle(
                            titleText: AppLocalizations.of(context)!
                                .form_scheduled_catchm_deposit),
                        const SizedBox(height: 8),
                        CustomDropdown(
                            fontSize: 12,
                            value: catchmentDeposit ??
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
                                catchmentDeposit = str;
                              });
                            }),
                        const SizedBox(height: 8),
                      ]),
                      const SizedBox(height: 12),
                      ContainerBottomDivider(children: [
                        // Estado de la tapa
                        ScheduledFormTitle(
                            titleText: AppLocalizations.of(context)!
                                .form_scheduled_catchm_top_status_1),
                        TopStatusOptions(
                          initialCheckboxStates: topStatusChecks_1,
                          onChanged: (Map<String, bool> checks) {
                            setState(() {
                              topStatusChecks_1 = checks;
                            });
                          },
                        ),
                      ]),
                      // Estado de la tapa - END
                      const SizedBox(height: 10.0),
                      ContainerBottomDivider(children: [
                        // Estado de la tapa
                        ScheduledFormTitle(
                            titleText: AppLocalizations.of(context)!
                                .form_scheduled_catchm_top_status_2),
                        TopStatusOptions(
                          initialCheckboxStates: topStatusChecks_2,
                          onChanged: (Map<String, bool> checks) {
                            setState(() {
                              topStatusChecks_2 = checks;
                            });
                          },
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
