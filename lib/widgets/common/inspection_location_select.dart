import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../constants/theme_constants.dart';
import '../../providers/selected_items_provider.dart';
import '../map_modal_location_select.dart';

class InspectionLocationSelect extends StatelessWidget {
  const InspectionLocationSelect({
    super.key,
    required this.selectedItemsProvider,
  });

  final SelectedItemsProvider? selectedItemsProvider;

  @override
  Widget build(BuildContext context) {
    return Consumer<SelectedItemsProvider>(
        builder: (context, selectedItemsProvider, child) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!.createTaskPage_selectUbicationTitle,
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const MapModalLocationSelect(),
              const SizedBox(width: 10.0),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: softGrey,
                  borderRadius: BorderRadius.circular(24.0),
                ),
                child: Wrap(
                  direction: Axis.vertical,
                  spacing: 8.0,
                  runSpacing: 15.0,
                  children: [
                    Chip(
                      backgroundColor: Colors.white70,
                      avatar: CircleAvatar(
                        backgroundColor: Colors.black38,
                        child: Icon(
                          Icons.location_on_outlined,
                          color: Colors.white70.withOpacity(1),
                          size: 20,
                        ),
                      ),
                      label: Text(
                          "lat: ${(selectedItemsProvider.inspectionPosition.latitude).toStringAsFixed(6)}"),
                    ),
                    Chip(
                      backgroundColor: Colors.white70,
                      avatar: CircleAvatar(
                        backgroundColor: Colors.black38,
                        child: Icon(
                          Icons.location_on_outlined,
                          color: Colors.white70.withOpacity(1),
                          size: 20,
                        ),
                      ),
                      label: Text(
                          " long: ${(selectedItemsProvider.inspectionPosition.longitude).toStringAsFixed(6)}"),
                    )
                  ],
                ),
              )
            ],
          ),
        ],
      );
    });
  }
}
