import 'package:flutter/material.dart';

import '../../../constants/theme_constants.dart';
import '../../../models/enums/element_type.dart';
import '../../../utils/colorUtils.dart';

class EntityIdContainer extends StatelessWidget {
  const EntityIdContainer({
    Key? key,
    required this.id,
    required this.elementType,
  }) : super(key: key);

  final String id;
  final ElementType elementType;

  @override
  Widget build(BuildContext context) {
    final initials = elementType.type;

    return Chip(
      backgroundColor: lightBackground,
      avatar: CircleAvatar(
        backgroundColor: getElementDefaultColor(elementType),
        child: Text(
          initials,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      label: Text(id),
    );
  }
}
