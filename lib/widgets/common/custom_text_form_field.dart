import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType textInputType;
  final int maxLength;
  final double width;
  final double height;
  final bool isTextBox;
  final int maxLines;
  final Color backgroundColor;

  const CustomTextFormField({
    required this.controller,
    required this.hintText,
    this.textInputType = TextInputType.text,
    this.maxLength = 12,
    Key? key,
    this.width = 180,
    this.isTextBox = false,
    this.maxLines = 1,
    this.height = 94,
    this.backgroundColor = const Color.fromRGBO(253, 255, 252, 1),
  }) : super(key: key);

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
        style: const TextStyle(
          fontSize: 16,
        ),
        controller: controller,
        //maxLength: maxLength,
        maxLengthEnforcement: MaxLengthEnforcement.none,
      ),
    );
  }
}
