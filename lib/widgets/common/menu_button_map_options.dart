import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../constants/theme_constants.dart';
import 'custom_elevated_button.dart';

class MultiSelectPopupMenuButton extends StatefulWidget {
  final List<String> texts;
  final Function(Set<int>) onIconsSelected;
  final Set<int> selectedIndices;
  final Function()? onClose;

  MultiSelectPopupMenuButton({
    required this.texts,
    required this.onIconsSelected,
    required this.selectedIndices,
    this.onClose,
  });

  @override
  _MultiSelectPopupMenuButtonState createState() =>
      _MultiSelectPopupMenuButtonState();
}

class _MultiSelectPopupMenuButtonState
    extends State<MultiSelectPopupMenuButton> {
  Set<int> selectedIndices = {};

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
            padding: const EdgeInsets.all(0),
            minimumSize: Size(circleSize, circleSize),
            shape: const OvalBorder(),
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
                CustomElevatedButton(
                  onPressed: () {
                    if (widget.onClose != null) {
                      widget.onClose!();
                    }
                    Navigator.of(context).pop(Set<int>.from(selectedIndices));
                  },
                  text: AppLocalizations.of(context)!.dialogCloseButton,
                ),
              ],
            ),
          ),
        ];
      },
    );
  }
}
