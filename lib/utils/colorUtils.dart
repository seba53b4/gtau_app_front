import 'package:flutter/material.dart';
import 'package:gtau_app_front/constants/theme_constants.dart';
import 'package:gtau_app_front/models/enums/element_type.dart';

Color getElementDefaultColor(ElementType elementType) {
  switch (elementType.type) {
    case 'T':
      return sectionDefaultColor;
    case 'R':
      return registerDefaultColor;
    case 'P':
      return lotDefaultColorChip;
    case 'C':
      return catchmentDefaultColor;
    default:
      return Colors.grey;
  }
}
