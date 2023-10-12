import 'package:flutter/material.dart';

class MultiSelectPopupMenuButton extends StatefulWidget {
  final List<IconData> icons;
  final Function(Set<int>) onIconsSelected;

  MultiSelectPopupMenuButton({
    required this.icons,
    required this.onIconsSelected,
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
    return PopupMenuButton<Set<int>>(
      onSelected: (Set<int> indices) {
        setState(() {
          selectedIndices = indices;
          widget.onIconsSelected(selectedIndices);
        });
      },
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<Set<int>>>[
          PopupMenuItem<Set<int>>(
            value: Set<int>.from(selectedIndices),
            child: Column(
              children: [
                for (int index = 0; index < widget.icons.length; index++)
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
                      Icon(widget.icons[index]),
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
      child: ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(0),
          minimumSize: Size(48, 48),
          shape: const CircleBorder(),
          primary: Colors.white,
        ),
        child: Icon(Icons.menu, color: Colors.black),
      ),
    );
  }
}
