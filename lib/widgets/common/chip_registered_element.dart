import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../constants/theme_constants.dart';

class RegistrationChip extends StatelessWidget {
  final bool isRegistered;

  const RegistrationChip({Key? key, required this.isRegistered})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: isRegistered ? primarySwatch[400] : Colors.grey,
      label: Text(
        isRegistered ? 'Registrado' : 'No Registrado',
        style: TextStyle(color: lightBackground),
      ),
    );
  }
}
