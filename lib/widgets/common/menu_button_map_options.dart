import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../constants/theme_constants.dart';

class MultiSelectPopupMenuButton extends StatefulWidget {
  final List<String> texts;
  final Function(Set<int>) onIconsSelected;
  final Set<int> selectedIndices;

  MultiSelectPopupMenuButton({
    required this.texts,
    required this.onIconsSelected,
    required this.selectedIndices,
  });

  @override
  _MultiSelectPopupMenuButtonState createState() =>
      _MultiSelectPopupMenuButtonState();
}

class _MultiSelectPopupMenuButtonState
    extends State<MultiSelectPopupMenuButton> {
  Set<int> selectedIndices = {};

  void _noop() {
    // Esta función no hace nada
  }

  @override
  Widget build(BuildContext context) {
    selectedIndices = widget.selectedIndices;
    double circleSize = kIsWeb ? 56 : 42;
    double sizeIcon = kIsWeb ? 24 : 22;

    return PopupMenuButton<Set<int>>(
      onSelected: (Set<int> indices) {
        setState(() {
          selectedIndices = indices;
          widget.onIconsSelected(selectedIndices);
        });
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: lightBackground,
        ),
        child: ElevatedButton(
          onPressed: null, // Puedes ajustar esta propiedad si es necesario
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.all(0),
            minimumSize: Size(circleSize, circleSize),
            shape: OvalBorder(),
          ),
          child: Icon(Icons.menu, size: sizeIcon, color: primarySwatch[500]!),
        ), // Icono del botón
      ),
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<Set<int>>>[
          PopupMenuItem<Set<int>>(
            value: Set<int>.from(selectedIndices),
            child: Column(
              children: [
                for (int index = 0; index < widget.texts.length; index++)
                  Row(
                    children: [
                      StatefulBuilder(
                        builder: (context, setState) {
                          return Checkbox(
                            value: selectedIndices.contains(index),
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  selectedIndices.add(index);
                                } else {
                                  selectedIndices.remove(index);
                                }
                              });
                            },
                          );
                        },
                      ),
                      Text(widget.texts[index]),
                    ],
                  ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(Set<int>.from(selectedIndices));
                  },
                  child: Text("Cerrar"),
                ),
              ],
            ),
          ),
        ];
      },
    );
  }
}
