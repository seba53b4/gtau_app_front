import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:gtau_app_front/widgets/common/custom_dropdown.dart';
import 'package:gtau_app_front/widgets/common/scheduled_form_common.dart';

import 'custom_labeled_checkbox.dart';
import 'custom_text_form_field.dart';

class ScheduledFormRegister extends StatefulWidget {
  const ScheduledFormRegister({Key? key}) : super(key: key);

  @override
  State<ScheduledFormRegister> createState() => _ScheduledFormRegisterState();
}

class _ScheduledFormRegisterState extends State<ScheduledFormRegister> {
  final observationsController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _observationsFocusNode = FocusNode();
  late StreamSubscription<bool> keyboardSubscription;

  @override
  void initState() {
    super.initState();
    keyboardSubscription =
        KeyboardVisibilityController().onChange.listen((bool visible) async {
      if (visible) {
        _scrollController.jumpTo(0.0);
        await Future.delayed(const Duration(milliseconds: 100));
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        _observationsFocusNode.requestFocus();
      } else {
        // Teclado cerrado
        _observationsFocusNode.unfocus();
      }
    });
  }

  @override
  void dispose() {
    keyboardSubscription.cancel();
    _observationsFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Tipo de pavimiento
            const ScheduledFormTitle(titleText: 'Tipo de pavimiento'),
            const SizedBox(height: 8),
            CustomDropdown(
                fontSize: 12,
                value: 'Sin Datos',
                items: [
                  'Acera',
                  'Hormigón',
                  'Balastro',
                  'Asfalto',
                  'Sin Datos'
                ],
                onChanged: (str) {
                  print(str);
                }),
            const SizedBox(height: 12),
            // Tipo de pavimiento - END
            const ScheduledFormTitle(titleText: 'Estado del registro'),
            const SizedBox(height: 8),
            CustomDropdown(
                fontSize: 12,
                value: 'No Apertura',
                items: ['Buen Estado', 'Mal Estado', 'No Apertura'],
                onChanged: (str) {}),
            const SizedBox(height: 12),
            // Estado del registro - END
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
                onTap: () {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 10),
                    curve: Curves.easeInOut,
                  );
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
    );
  }
}
