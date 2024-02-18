import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtau_app_front/constants/theme_constants.dart';

import '../models/enums/element_type.dart';
import 'common/custom_text_button.dart';
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
            color: primarySwatch[200],
            height: 50,
            child: Container(
              height: 24,
              alignment: Alignment.center,
              child: Text(AppLocalizations.of(context)!.component_detail_title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: lightBackground,
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
            CustomTextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onClose!();
              },
              text: AppLocalizations.of(context)!.dialogCloseButton,
              //   style: const TextStyle(
              //       fontSize: 18, color: Color.fromRGBO(96, 166, 27, 1)),
              // ),
            ),
          ],
          backgroundColor: lightBackground);
    },
  );
}
