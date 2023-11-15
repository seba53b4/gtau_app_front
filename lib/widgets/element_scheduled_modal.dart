import 'package:flutter/material.dart';
import 'package:gtau_app_front/constants/theme_constants.dart';

import '../models/enums/element_type.dart';
import 'common/scheduled_form_widget.dart';

typedef void OnCloseCallback();

_parseTitle(BuildContext context, ElementType elementType) {
  switch (elementType.type) {
    case 'C':
      return 'Captacion';
    case 'R':
      return 'Registro';
    case 'T':
      return 'Tramo';
    default:
      throw Exception('No existe el tipo ${elementType.type}');
  }
}

void showScheduledElementModal(BuildContext context, ElementType elementType,
    OnCloseCallback? onClose) async {
  double dialogWidth = MediaQuery.of(context).size.width * 0.82;
  double scrollHeight = MediaQuery.of(context).size.height * 0.75;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
          shadowColor: primarySwatch[200],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primarySwatch[300]!, primarySwatch[500]!],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              height: 40,
              alignment: Alignment.center,
              child: Text(
                _parseTitle(context, elementType),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: lightBackground,
                  letterSpacing: 1,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          content: SizedBox(
            height: scrollHeight,
            width: dialogWidth,
            child: ScheduledFormWidget(elementType: elementType),
          ),
          actions: null,
          // actions: <Widget>[
          //   TextButton(
          //     onPressed: () {
          //       Navigator.of(context).pop();
          //       onClose!();
          //     },
          //     child: Text(
          //       AppLocalizations.of(context)!.dialogCloseButton,
          //       style: const TextStyle(
          //           fontSize: 18, color: Color.fromRGBO(96, 166, 27, 1)),
          //     ),
          //   ),
          // ],
          backgroundColor: lightBackground);
    },
  );
}
