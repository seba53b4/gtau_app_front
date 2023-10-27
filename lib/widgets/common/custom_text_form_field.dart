import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType textInputType;
  final int maxLength;
  final double width;

  const CustomTextFormField({
    required this.controller,
    required this.hintText,
    this.textInputType = TextInputType.text,
    this.maxLength = 12,
    Key? key,
    this.width = 200,
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
      child: TextFormField(
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          hintText: hintText,
          border: const OutlineInputBorder(),
        ),
        controller: controller,
        maxLength: maxLength,
        maxLengthEnforcement: MaxLengthEnforcement.none,
      ),
    );
  }
}
