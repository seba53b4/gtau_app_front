import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtau_app_front/constants/theme_constants.dart';
import 'package:gtau_app_front/models/enums/message_type.dart';
import 'package:provider/provider.dart';

import '../providers/selected_items_provider.dart';
import '../viewmodels/catchment_viewmodel.dart';
import '../viewmodels/lot_viewmodel.dart';
import '../viewmodels/register_viewmodel.dart';
import '../viewmodels/section_viewmodel.dart';
import 'common/custom_elevated_button.dart';
import 'map_component_location_select.dart';

const double ratioWeb = 0.82;
const double ratioTablet = 0.75;
const double ratioMobile = 0.7780;

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
  SelectedItemsProvider selectedItemsProvider =
      context.read<SelectedItemsProvider>();

  void clearElementsFetched() {
    context.read<RegisterViewModel>().reset();
    context.read<SectionViewModel>().reset();
    context.read<LotViewModel>().reset();
    context.read<CatchmentViewModel>().reset();
  }

  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: "Map Modal",
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (_, __, ___) {
      return Scaffold(
        appBar: AppBar(
            backgroundColor: primarySwatch,
            centerTitle: true,
            leading: IconButton(
                icon: Icon(
                  Icons.close,
                  color: lightBackground,
                  size: 18,
                ),
                onPressed: () {
                  Navigator.pop(context);
                }),
            title: Text(
              AppLocalizations.of(context)!.map_modal_add_elements_title,
              style: TextStyle(color: lightBackground, fontSize: 20),
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
                child: const MapComponentLocationSelect(isModal: true),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 50,
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  CustomElevatedButton(
                    onPressed: () {
                      selectedItemsProvider.clearAllElements();
                      clearElementsFetched();
                      Navigator.of(context).pop();
                    },
                    messageType: MessageType.error,
                    text: AppLocalizations.of(context)!.buttonCancelLabel,
                  ),
                  const SizedBox(width: 10.0),
                  CustomElevatedButton(
                    onPressed: () {
                      selectedItemsProvider.saveCurrentPositionAsInitial();
                      clearElementsFetched();
                      Navigator.of(context).pop();
                    },
                    messageType: MessageType.success,
                    text: AppLocalizations.of(context)!.buttonAcceptLabel,
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

class MapModalLocationSelect extends StatelessWidget {
  const MapModalLocationSelect({super.key});

  @override
  Widget build(BuildContext context) {
    final color = primarySwatch[300];
    return Material(
      color: Colors.white,
      child: Center(
        child: Ink(
          decoration: ShapeDecoration(
            color: color,
            shape: const CircleBorder(),
          ),
          child: IconButton(
            icon: const Icon(Icons.location_on),
            color: Colors.white,
            onPressed: () {
              _showMapModal(context);
            },
          ),
        ),
      ),
    );
  }
}
