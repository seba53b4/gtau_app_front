import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtau_app_front/constants/app_constants.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hintText;
  final TextInputType textInputType;
  final int maxLength;
  final double width;
  final double height;
  final bool isTextBox;
  final int maxLines;
  final Color backgroundColor;
  final double fontSize;
  final bool useValidation;
  final bool readOnly;
  final VoidCallback? onTap;

  const CustomTextFormField({
    required this.controller,
    this.focusNode,
    required this.hintText,
    this.textInputType = TextInputType.text,
    this.maxLength = 12,
    Key? key,
    this.width = AppConstants.textFieldWidth,
    this.isTextBox = false,
    this.maxLines = 1,
    this.height = 94,
    this.backgroundColor = AppConstants.backgroundColor,
    this.fontSize = 16,
    this.useValidation = true,
    this.readOnly = false,
    this.onTap,
  }) : super(key: key);

  String? _validateInput(BuildContext context, String? value) {
    if (useValidation && (value == null || value.isEmpty)) {
      return AppLocalizations.of(context)!.form_field_mandatory;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    TextInputType keyboardType;
    List<TextInputFormatter> inputFormatters = [];

    if (textInputType == TextInputType.number) {
      keyboardType = TextInputType.number;
      inputFormatters = [FilteringTextInputFormatter.digitsOnly];
    } else {
      keyboardType = TextInputType.text;
    }

    return SizedBox(
      width: width,
      height: height,
      child: TextFormField(
        onTap: onTap,
        focusNode: focusNode,
        keyboardType: keyboardType,

        inputFormatters: inputFormatters,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isTextBox ? 24 : 48),
          ),
          contentPadding: isTextBox
              ? const EdgeInsets.symmetric(vertical: 16, horizontal: 16)
              : const EdgeInsets.symmetric(vertical: 21, horizontal: 8),
          filled: true,
          fillColor: backgroundColor,
        ),
        style: TextStyle(
          fontSize: fontSize,
        ),
        controller: controller,
        enabled: !readOnly,
        //maxLength: maxLength,
        maxLengthEnforcement: MaxLengthEnforcement.none,
        validator:
            useValidation ? (value) => _validateInput(context, value) : null,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }
}
