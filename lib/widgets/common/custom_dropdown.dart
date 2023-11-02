import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueSetter<String> onChanged;
  final double width;
  final double height;
  final double circularBorderRadius;
  final Color backgroundColor;
  final double fontSize;

  const CustomDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    this.width = 160,
    this.circularBorderRadius = 48.0,
    this.height = 54,
    this.backgroundColor = const Color.fromRGBO(253, 255, 252, 1),
    this.fontSize = 14.0,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: DropdownButtonFormField<String>(
        borderRadius: BorderRadius.circular(circularBorderRadius),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(circularBorderRadius),
          ),
          filled: true,
          fillColor: backgroundColor,
        ),
        value: value,
        onChanged: (value) {
          onChanged(value!);
        },
        alignment: AlignmentDirectional.center,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            alignment: Alignment.center,
            child: Center(
              child: Text(
                item,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
