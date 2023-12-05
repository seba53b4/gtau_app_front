import 'package:flutter/material.dart';
import 'package:gtau_app_front/constants/app_constants.dart';

class TextFieldFilter extends StatelessWidget {
  const TextFieldFilter(
      {Key? key,
      required this.valueSetter,
      required this.value,
      required this.label})
      : super(key: key);

  final Function(String value) valueSetter;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(
        hintText: label,
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        filled: true,
        fillColor: AppConstants.backgroundColor,
      ),
      onChanged: (newValue) {
        valueSetter(newValue);
      },
    );
  }
}
