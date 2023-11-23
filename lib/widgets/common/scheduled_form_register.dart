import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:gtau_app_front/models/enums/message_type.dart';
import 'package:gtau_app_front/widgets/common/custom_dropdown.dart';
import 'package:gtau_app_front/widgets/common/custom_elevated_button.dart';
import 'package:gtau_app_front/widgets/common/scheduled_form_common.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../utils/element_functions.dart';
import 'custom_labeled_checkbox.dart';
import 'custom_text_form_field.dart';
import 'custom_textfield.dart';

class ScheduledFormRegister extends StatefulWidget {
  const ScheduledFormRegister({Key? key}) : super(key: key);

  @override
  State<ScheduledFormRegister> createState() => _ScheduledFormRegisterState();
}

class _ScheduledFormRegisterState extends State<ScheduledFormRegister> {
  final observationsController = TextEditingController();
  final AutoScrollController _scrollController = AutoScrollController();
  final FocusNode _observationsFocusNode = FocusNode();
  late StreamSubscription<bool> keyboardSubscription;
  final _cotaController = TextEditingController();
  final _depthController = TextEditingController();
  final _cotaDropdownFocusNode = FocusNode();
  final _depthDropdownFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    keyboardSubscription =
        KeyboardVisibilityController().onChange.listen((bool visible) {
      if (visible) {
        scrollToFocusedDropdown();
      }
    });
  }

  @override
  void dispose() {
    keyboardSubscription.cancel();
    _observationsFocusNode.dispose();
    _cotaController.dispose();
    _depthController.dispose();
    _cotaDropdownFocusNode.dispose();
    _depthDropdownFocusNode.dispose();
    super.dispose();
  }

  void scrollToFocusedDropdown() {
    if (_cotaDropdownFocusNode.hasFocus) {
      scrollToFocusedElement(
        focusedNode: _cotaDropdownFocusNode,
        scrollController: _scrollController,
      );
    } else if (_depthDropdownFocusNode.hasFocus) {
      scrollToFocusedElement(
        focusedNode: _depthDropdownFocusNode,
        scrollController: _scrollController,
      );
    } else if (_observationsFocusNode.hasFocus) {
      scrollToFocusedElement(
        focusedNode: _observationsFocusNode,
        scrollController: _scrollController,
      );
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
                          child: const Row(
                            children: [
                              Text('ID:'),
                              SizedBox(width: 8),
                              Text('123456'),
                            ],
                          ),
                        ),
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
                          child: const Row(
                            children: [
                              Text('Tipo:'),
                              SizedBox(width: 8),
                              Text('BT')
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
                  const ScheduledFormTitle(titleText: 'Catastro'),
                  const SizedBox(height: 8),
                  CustomDropdown(
                      fontSize: 12,
                      value: 'Vacío',
                      items: const ['Nuevo', 'Ajustado', 'Vacío'],
                      onChanged: (str) {}),
                  const SizedBox(height: 12),
                  // Tipo de pavimiento
                  const ScheduledFormTitle(titleText: 'Tipo de pavimiento'),
                  const SizedBox(height: 8),
                  CustomDropdown(
                      fontSize: 12,
                      value: 'Sin Datos',
                      items: const ['Acera', 'Calzada', 'Sin Datos'],
                      onChanged: (str) {}),
                  const SizedBox(height: 12),
                  const ScheduledFormTitle(titleText: 'Estado del registro'),
                  const SizedBox(height: 8),
                  CustomDropdown(
                      fontSize: 12,
                      value: 'Sin Datos',
                      items: const [
                        'Bueno',
                        'Malo',
                        'No Apertura',
                        'Sin Datos'
                      ],
                      onChanged: (str) {}),
                  const SizedBox(height: 12),
                  const ScheduledFormTitle(titleText: 'Cota de tapa'),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _cotaController,
                    width: 98,
                    keyboardType: TextInputType.number,
                    focusNode: _cotaDropdownFocusNode,
                    hasError: false,
                  ),
                  const SizedBox(height: 12),
                  const ScheduledFormTitle(titleText: 'Profundidad (m)'),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _depthController,
                    width: 98,
                    keyboardType: TextInputType.number,
                    focusNode: _depthDropdownFocusNode,
                    hasError: false,
                  ),
                  const SizedBox(height: 12),
                  const ScheduledFormTitle(titleText: 'Apertura'),
                  const SizedBox(height: 8),
                  CustomDropdown(
                      fontSize: 12,
                      value: 'No Localizado',
                      items: const [
                        'Si Apertura',
                        'No Apertura',
                        'No Localizado'
                      ],
                      onChanged: (str) {}),
                  const SizedBox(height: 12),
                  // Estado de la tapa
                  const ScheduledFormTitle(titleText: 'Estado de la tapa'),
                  CustomLabeledCheckbox(
                    label: 'Bien',
                    onChanged: (value) {},
                  ),
                  CustomLabeledCheckbox(
                    label: 'Faltante',
                    onChanged: (value) {},
                  ),
                  CustomLabeledCheckbox(
                    label: 'Hundida',
                    onChanged: (value) {},
                  ),
                  CustomLabeledCheckbox(
                    label: 'Marco descalzado',
                    onChanged: (value) {},
                  ),
                  CustomLabeledCheckbox(
                    label: 'Marco roto',
                    onChanged: (value) {},
                  ),
                  CustomLabeledCheckbox(
                    label: 'Provisoria',
                    onChanged: (value) {},
                  ),
                  CustomLabeledCheckbox(
                    label: 'Rota',
                    onChanged: (value) {},
                  ),
                  CustomLabeledCheckbox(
                    label: 'Soldada/Sellada',
                    onChanged: (value) {},
                  ),
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
                      // onTap: () {
                      //   Future.delayed(const Duration(milliseconds: 100), () {
                      //     _scrollController.animateTo(
                      //       _scrollController.position.maxScrollExtent,
                      //       duration: const Duration(milliseconds: 300),
                      //       curve: Curves.easeInOut,
                      //     );
                      //   });
                      // },
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
                text: 'Cancelar'),
            const SizedBox(width: 16),
            CustomElevatedButton(onPressed: () {}, text: 'Aceptar'),
          ],
        ),
      ],
    );
  }
}
