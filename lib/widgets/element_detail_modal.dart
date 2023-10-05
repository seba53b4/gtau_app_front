import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Container(
            color: const Color.fromRGBO(96, 166, 27, 1),
            height: 50,
            child: Container(
              height: 24,
              alignment: Alignment.center,
              child: Text(AppLocalizations.of(context)!.component_detail_title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Color.fromRGBO(14, 45, 9, 1),
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
            ),
          ),
          content: SizedBox(
            height: 500,
            child: SingleChildScrollView(
              child: DetailElementWidget(elementType: elementType),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onClose!();
              },
              child: Text(
                AppLocalizations.of(context)!.dialogCloseButton,
                style: const TextStyle(
                    fontSize: 18, color: Color.fromRGBO(96, 166, 27, 1)),
              ),
            ),
          ],
          backgroundColor: const Color.fromRGBO(242, 242, 242, 1));
    },
  );
}
