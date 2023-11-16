import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:gtau_app_front/widgets/common/custom_textfield.dart';
import 'package:gtau_app_front/widgets/common/scheduled_form_common.dart';

import '../../models/enums/message_type.dart';
import 'custom_dropdown.dart';
import 'custom_elevated_button.dart';
import 'custom_labeled_checkbox.dart';
import 'custom_text_form_field.dart';

class ScheduledFormSection extends StatefulWidget {
  const ScheduledFormSection({Key? key}) : super(key: key);

  @override
  State<ScheduledFormSection> createState() => _ScheduledFormSection();
}

class _ScheduledFormSection extends State<ScheduledFormSection> {
  final observationsController = TextEditingController();
  final _diamController = TextEditingController();
  final _longitudeController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _observationsFocusNode = FocusNode();
  late StreamSubscription<bool> keyboardSubscription;
  late bool _observationsSelected = false;

  @override
  void initState() {
    super.initState();
    keyboardSubscription =
        KeyboardVisibilityController().onChange.listen((bool visible) async {
      if (visible && _observationsSelected) {
        _scrollController.jumpTo(0.0);
        await Future.delayed(const Duration(milliseconds: 105));
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
      _observationsSelected = false;
    });
  }

  @override
  void dispose() {
    keyboardSubscription.cancel();
    _diamController.dispose();
    _longitudeController.dispose();
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
                              Text('PL')
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
                  // Diámentro (m)
                  const ScheduledFormTitle(titleText: 'Diámentro (m)'),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _diamController,
                    width: 98,
                    keyboardType: TextInputType.number,
                    hasError: false,
                  ),
                  const SizedBox(height: 12),
                  // Diámentro (m) - END
                  // Diámentro (m)
                  const ScheduledFormTitle(titleText: 'Longitud (m)'),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _longitudeController,
                    width: 98,
                    keyboardType: TextInputType.number,
                    hasError: false,
                  ),
                  const SizedBox(height: 12),
                  // Diámentro (m) - END
                  const ScheduledFormTitle(
                      titleText: 'Niveles de sedimentación'),
                  const SizedBox(height: 8),
                  CustomDropdown(
                      fontSize: 12,
                      width: 110,
                      value: '0 - 15 %',
                      items: const ['0 - 15 %', '15 - 50 %', '+ 50 %'],
                      onChanged: (str) {}),
                  const SizedBox(height: 12),
                  // Niveles de sedimentación - END
                  const ScheduledFormTitle(titleText: 'Inspeccionado desde'),
                  CustomLabeledCheckbox(
                    label: 'Aguas arriba',
                    onChanged: (value) {},
                  ),
                  CustomLabeledCheckbox(
                    label: 'Aguas abajo',
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 12),
                  // Patologías
                  const ScheduledFormTitle(titleText: 'Patologías'),
                  CustomLabeledCheckbox(
                    label: 'Daño',
                    onChanged: (value) {},
                  ),
                  CustomLabeledCheckbox(
                    label: 'Raíz',
                    onChanged: (value) {},
                  ),
                  CustomLabeledCheckbox(
                    label: 'Piedras o Escombros',
                    onChanged: (value) {},
                  ),
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
                      onTap: () {
                        _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 10),
                          curve: Curves.easeInOut,
                        );
                        setState(() {
                          _observationsSelected = !_observationsSelected;
                        });
                      },
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
