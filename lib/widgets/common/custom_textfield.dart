import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool hasError;
  final bool? filledBackground;
  final Color? fillColor;
  final double? width;
  final FocusNode? focusNode;
  final bool? readOnly;

  CustomTextField({
    required this.controller,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    required this.hasError,
    this.filledBackground,
    this.fillColor,
    this.width,
    this.focusNode,
    this.readOnly,
  });

  @override
  Widget build(BuildContext context) {
    double inputWidth;
    if (kIsWeb) {
      inputWidth = 220.0;
    } else {
      inputWidth = 220.0;
    }
    return Container(
      width: width ?? inputWidth,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        readOnly: readOnly ?? false,
        focusNode: focusNode,
        decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(24.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  const BorderSide(color: Color.fromRGBO(96, 166, 27, 1)),
              borderRadius: BorderRadius.circular(24.0),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(24.0),
            ),
            filled: filledBackground ?? true,
            fillColor: fillColor ?? Colors.white,
            errorText: hasError ? 'Campo inválido' : null,
            hintText: hintText,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16)),
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
      ),
    );
  }
}
