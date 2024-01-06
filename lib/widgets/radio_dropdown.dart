import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../constants/theme_constants.dart';

class SingleSelectDropdown extends StatefulWidget {
  final List<String> items;
  final int selectedItemIndex;
  final Function(int) onChanged;

  SingleSelectDropdown({
    required this.items,
    required this.selectedItemIndex,
    required this.onChanged,
  });

  @override
  _SingleSelectDropdownState createState() => _SingleSelectDropdownState();
}

class _SingleSelectDropdownState extends State<SingleSelectDropdown> {
  @override
  Widget build(BuildContext context) {
    double circleSize = kIsWeb ? 56 : 42;
    double sizeIcon = kIsWeb ? 24 : 22;

    return PopupMenuButton<int>(
      onSelected: (int newIndex) {
        setState(() {
          widget.onChanged(newIndex);
        });
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: lightBackground,
        ),
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(0),
            minimumSize: Size(circleSize, circleSize),
            shape: const OvalBorder(),
          ),
          child: Icon(Icons.map_outlined,
              size: sizeIcon, color: primarySwatch[500]!),
        ),
      ),
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<int>>[
          PopupMenuItem<int>(
            value: widget.selectedItemIndex,
            child: Column(
              children: [
                for (int index = 0; index < widget.items.length; index++)
                  ListTile(
                    title: Text(widget.items[index]),
                    onTap: () {
                      widget.onChanged(index);
                      Navigator.pop(context);
                    },
                    leading: Radio<int>(
                      value: index,
                      groupValue: widget.selectedItemIndex,
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          widget.onChanged(newValue);
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                // Agrega cualquier otro widget aquí según sea necesario
              ],
            ),
          ),
        ];
      },
    );
  }
}
