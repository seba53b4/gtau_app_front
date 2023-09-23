import 'package:flutter/material.dart';
import 'package:gtau_app_front/widgets/common/section_detail.dart';

typedef void OnCloseCallback();

void showElementModal(BuildContext context, OnCloseCallback onClose) {
  final numWorkController = TextEditingController();

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
            fontSize: 20,
          ),
        ),
        content: SingleChildScrollView(
          child: SectionDetail(),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onClose();
            },
            child: Text("Cerrar"),
          ),
        ],
      );
    },
  );
}
