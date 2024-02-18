import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtau_app_front/constants/theme_constants.dart';

class CustomToggleButtons extends StatefulWidget {
  final List<VoidCallback> onPressedList;

  const CustomToggleButtons({Key? key, required this.onPressedList})
      : super(key: key);

  @override
  State<CustomToggleButtons> createState() => _CustomToggleButtonsState();
}

class _CustomToggleButtonsState extends State<CustomToggleButtons> {
  int selectedIndex = 0;
  double buttonWidth = 176;
  double buttonHeight = 44;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomToggleButton(
            text: AppLocalizations.of(context)!.createTaskPage_scheduled,
            index: 0,
            isSelected: selectedIndex == 0,
            onPressed: () {
              setState(() {
                selectedIndex = 0;
              });
              widget.onPressedList[0]();
            },
            width: buttonWidth,
            height: buttonHeight,
          ),
          const SizedBox(width: 24, height: 24.0),
          CustomToggleButton(
            text: AppLocalizations.of(context)!.createTaskPage_inspection,
            index: 1,
            isSelected: selectedIndex == 1,
            onPressed: () {
              setState(() {
                selectedIndex = 1;
              });
              widget.onPressedList[1]();
            },
            width: buttonWidth,
            height: buttonHeight,
          ),
        ],
      ),
    );
  }
}

class CustomToggleButton extends StatelessWidget {
  final String text;
  final int index;
  final bool isSelected;
  final VoidCallback onPressed;
  final double width;
  final double height;

  const CustomToggleButton({
    super.key,
    required this.text,
    required this.index,
    required this.isSelected,
    required this.onPressed,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    double circularBorder = 24;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isSelected ? primarySwatch[500] : primarySwatch[50],
          borderRadius: BorderRadius.circular(circularBorder),
          border: Border.all(
            width: 1,
            color: primarySwatch[100]!,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: lightBackground,
          ),
        ),
      ),
    );
  }
}
