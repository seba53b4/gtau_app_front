import 'package:flutter/material.dart';
import 'package:gtau_app_front/widgets/map_component.dart';
import 'package:provider/provider.dart';

import '../providers/selected_items_provider.dart';


void _showMapModal(BuildContext context) {
  double screenHeight = MediaQuery.of(context).size.height;
  double modalHeight = screenHeight * 0.8;

  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: "Modal",
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (_, __, ___) {
      return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.white,
            centerTitle: true,
            leading: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.black,
                  size: 12,
                ),
                onPressed: (){
                  Navigator.pop(context);
                }
            ),
            title: const Text(
              "Modal",
              style: TextStyle(color: Colors.black87, fontFamily: 'Overpass', fontSize: 20),
            ),
            elevation: 0.0
        ),
        body: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: modalHeight,
                child: const MapComponent(isModal: true),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cerrar'),
              ),
            ],
          ),
        ),
      );
    },
  );
}


class MapModal extends StatelessWidget {
  const MapModal({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedItemsProvider = context.read<SelectedItemsProvider>();
    selectedItemsProvider.activateMultipleSelection();
    return ElevatedButton(
        onPressed: () {
          _showMapModal(context);
        },
        child: const Text('Open Modal'),
      );
  }
}
