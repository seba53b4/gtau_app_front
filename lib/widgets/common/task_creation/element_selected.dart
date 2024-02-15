import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../constants/theme_constants.dart';
import '../../../models/enums/element_type.dart';
import '../../../providers/selected_items_provider.dart';
import '../../../screens/TaskCreationScreen.dart';
import '../../map_modal.dart';
import 'entity_container.dart';

class ElementsSelected extends StatelessWidget {
  const ElementsSelected({
    super.key,
    required this.widget,
  });

  final TaskCreationScreen widget;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.detail,
      child: Consumer<SelectedItemsProvider>(
        builder: (context, selectedItemsProvider, child) {
          final elementsList = <EntityIdContainer>[];

          elementsList
              .addAll(selectedItemsProvider.selectedPolylines.map((element) {
            return EntityIdContainer(
              id: element.value,
              elementType: ElementType.section,
            );
          }));

          elementsList
              .addAll(selectedItemsProvider.selectedCatchments.map((element) {
            return EntityIdContainer(
              id: element.value,
              elementType: ElementType.catchment,
            );
          }));

          elementsList
              .addAll(selectedItemsProvider.selectedRegisters.map((element) {
            return EntityIdContainer(
              id: element.value,
              elementType: ElementType.register,
            );
          }));

          elementsList.addAll(selectedItemsProvider.selectedLots.map((element) {
            return EntityIdContainer(
              id: element.value,
              elementType: ElementType.lot,
            );
          }));

          int splitValue = kIsWeb ? 4 : 2;

          final List<List<EntityIdContainer>> splitList = [];
          for (int i = 0; i < elementsList.length; i += splitValue) {
            int endIndex = i + splitValue;
            if (endIndex > elementsList.length) {
              endIndex = elementsList.length;
            }
            splitList.add(elementsList.sublist(i, endIndex));
          }

          double paddingElements = kIsWeb ? 8 : 4;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)!.elementsTitle,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const MapModal(),
                  const SizedBox(width: 8),
                  Container(
                      // constraints: BoxConstraints(maxWidth: 600),
                      // Establece el ancho máximo
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: softGrey,
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      child: elementsList.isNotEmpty
                          ? Column(
                              children: splitList.map((subList) {
                                return Row(
                                  children: subList.map((item) {
                                    return Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: paddingElements,
                                          vertical: paddingElements - 2),
                                      child: item,
                                    );
                                  }).toList(),
                                );
                              }).toList(),
                            )
                          : Text(
                              AppLocalizations.of(context)!
                                  .no_elements_registered,
                              style: const TextStyle(fontSize: 16.0),
                            )),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!
                    .createTaskPage_selectUbicationTitle,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: softGrey,
                  borderRadius: BorderRadius.circular(24.0),
                ),
                child: Wrap(
                  direction: kIsWeb ? Axis.horizontal : Axis.vertical,
                  spacing: kIsWeb ? 8.0 : 4,
                  runSpacing: kIsWeb ? 8.0 : 6,
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
                          "lat: ${selectedItemsProvider.inspectionPosition.latitude}"),
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
                          " long: ${selectedItemsProvider.inspectionPosition.longitude}"),
                    )
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
