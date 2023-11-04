import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtau_app_front/widgets/map_component.dart';
import 'package:provider/provider.dart';

import '../providers/selected_items_provider.dart';
import 'common/custom_elevated_button.dart';

const double ratioWeb = 0.8;
const double ratioTablet = 0.75;
const double ratioMobile = 0.735;

double _getHeightModalOnDevice(BuildContext context) {
  double screenHeight = MediaQuery.of(context).size.height;

  if (MediaQuery.of(context).size.shortestSide < 600) {
    return screenHeight * ratioMobile;
  } else if (kIsWeb) {
    return screenHeight * ratioWeb;
  } else {
    return screenHeight * ratioTablet;
  }
}

void _showMapModal(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: "Map Modal",
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
                onPressed: () {
                  Navigator.pop(context);
                }),
            title: Text(
              AppLocalizations.of(context)!.map_modal_add_elements_title,
              style: const TextStyle(
                  color: Colors.black87, fontFamily: 'Overpass', fontSize: 20),
            ),
            elevation: 0.0),
        body: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: _getHeightModalOnDevice(context),
                child: MapComponent(isModal: true),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 50,
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child:
                        Text(AppLocalizations.of(context)!.buttonCancelLabel),
                  ),
                  const SizedBox(width: 10.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child:
                        Text(AppLocalizations.of(context)!.buttonAcceptLabel),
                  ),
                ]),
              )
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
    return CustomElevatedButton(
      onPressed: () {
        _showMapModal(context);
      },
      text: AppLocalizations.of(context)!.map_modal_add_elements_button,
    );
  }
}
