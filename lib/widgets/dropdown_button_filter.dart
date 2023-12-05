import 'package:flutter/material.dart';
import 'package:gtau_app_front/constants/app_constants.dart';

import '../models/value_label.dart';

class DropdownButtonFilter extends StatefulWidget {
  const DropdownButtonFilter(
      {Key? key,
      required this.suggestions,
      required this.valueSetter,
      required this.dropdownValue,
      required this.label,
      required this.enabled})
      : super(key: key);

  final List<ValueLabel> suggestions;
  final Function(String value) valueSetter;
  final String dropdownValue;
  final String label;
  final bool enabled;

  @override
  State<DropdownButtonFilter> createState() => _DropdownButtonFilterState();
}

class _DropdownButtonFilterState extends State<DropdownButtonFilter> {
  _DropdownButtonFilterState();

  String selectedValue = "";

  @override
  Widget build(BuildContext context) {
    selectedValue =
        selectedValue.isEmpty ? widget.dropdownValue : selectedValue;
    final List<DropdownMenuEntry<String>> entries = widget.suggestions
        .map(
          (e) => DropdownMenuEntry<String>(
              value: e.value, label: e.label, enabled: true),
        )
        .toList();

    return DropdownMenu<String>(
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        filled: true,
        fillColor: AppConstants.backgroundColor,
      ),
      initialSelection: selectedValue,
      controller: TextEditingController(),
      label: Text(widget.label),
      enabled: widget.enabled,
      dropdownMenuEntries: entries,
      onSelected: (String? newValue) {
        setState(() {
          selectedValue = newValue!;
          widget.valueSetter(newValue);
        });
      },
    );
  }
}
