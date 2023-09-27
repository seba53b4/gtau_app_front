import 'package:flutter/material.dart';

import '../models/enums/element_type.dart';
import 'common/detail_element_widget.dart';

typedef void OnCloseCallback();

void showElementModal(
    BuildContext context, ElementType elementType, OnCloseCallback? onClose) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          "Detalle del tramo",
          style: TextStyle(
            color: Colors.black87,
            fontFamily: 'Overpass',
            fontSize: 12,
          ),
        ),
        content: SingleChildScrollView(
          child: DetailElementWidget(elementType: elementType),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onClose!();
            },
            child: Text("Cerrar"),
          ),
        ],
      );
    },
  );
}
