import 'package:flutter/material.dart';
import 'package:gtau_app_front/constants/theme_constants.dart';

class CustomLabeledCheckbox extends StatefulWidget {
  final String label;
  final ValueSetter<bool?>? onChanged;
  final bool initialValue;

  const CustomLabeledCheckbox({
    Key? key,
    required this.label,
    this.onChanged,
    this.initialValue = false,
  }) : super(key: key);

  @override
  _CustomLabeledCheckbox createState() => _CustomLabeledCheckbox();
}

class _CustomLabeledCheckbox extends State<CustomLabeledCheckbox> {
  late bool _isChecked;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    double sizeCheckBox = 16;

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: const TextStyle(fontSize: 16),
            ),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isChecked ? primarySwatch : Colors.transparent,
                border: Border.all(
                  color: primarySwatch[600]!,
                ),
                boxShadow: [
                  if (_isChecked)
                    BoxShadow(
                      color: primarySwatch.withOpacity(0.35),
                      blurRadius: 5,
                      spreadRadius: 2,
                    ),
                ],
              ),
              child: ClipOval(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _isChecked = !_isChecked;
                        widget.onChanged?.call(_isChecked);
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: _isChecked
                          ? Icon(
                              Icons.check,
                              size: sizeCheckBox,
                              color: lightBackground,
                            )
                          : SizedBox(
                              width: sizeCheckBox,
                              height: sizeCheckBox,
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
