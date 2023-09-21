import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
          child: Container(
            margin:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!
                        .default_placeHolderInputText,
                    border: const OutlineInputBorder(),
                  ),
                  controller: numWorkController,
                ),
                const SizedBox(height: 10.0),
              ],
            ),
          ),
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
