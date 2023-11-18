import 'package:flutter/material.dart';

import '../models/value_label.dart';

class DropdownButtonFilter extends StatefulWidget {
  const DropdownButtonFilter(
      {Key? key,
      required this.suggestions,
      required this.valueSetter,
      required this.dropdownValue,
      required this.label})
      : super(key: key);

  final List<ValueLabel> suggestions;
  final Function(String value) valueSetter;
  final String dropdownValue;
  final String label;

  @override
  State<DropdownButtonFilter> createState() => _DropdownButtonFilterState(
      suggestions, valueSetter, dropdownValue, label);
}

class _DropdownButtonFilterState extends State<DropdownButtonFilter> {
  _DropdownButtonFilterState(
      this.suggestions, this.valueSetter, this.dropdownValue, this.label);

  final Function(String value) valueSetter;
  final String dropdownValue;
  final List<ValueLabel> suggestions;
  final String label;

  String selectedValue = "";

  @override
  Widget build(BuildContext context) {
    selectedValue = selectedValue.isEmpty ? dropdownValue : selectedValue;
    final List<DropdownMenuEntry<String>> entries = suggestions
        .map(
          (e) => DropdownMenuEntry<String>(
              value: e.value, label: e.label, enabled: true),
        )
        .toList();

    return DropdownMenu<String>(
      initialSelection: selectedValue,
      controller: TextEditingController(),
      label: Text(label),
      dropdownMenuEntries: entries,
      onSelected: (String? newValue) {
        setState(() {
          selectedValue = newValue!;
          valueSetter(newValue);
        });
      },
    );
  }
}
