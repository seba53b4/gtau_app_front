import 'package:flutter/material.dart';

class ScheduledFormTitle extends StatefulWidget {
  final String titleText;

  const ScheduledFormTitle({
    Key? key,
    required this.titleText,
  }) : super(key: key);

  @override
  State<ScheduledFormTitle> createState() => _ScheduledFormTitleState();
}

class _ScheduledFormTitleState extends State<ScheduledFormTitle> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(widget.titleText, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: 4),
          child: Divider(color: Colors.grey, thickness: 1),
        ),
      ],
    );
  }
}
