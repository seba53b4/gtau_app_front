import 'package:flutter/cupertino.dart';
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
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: softGrey,
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    child: Wrap(
                      spacing: 15.0,
                      runSpacing: 15.0,
                      children: elementsList.isNotEmpty
                          ? elementsList
                          : [
                              Text(
                                AppLocalizations.of(context)!
                                    .no_elements_registered,
                                style: const TextStyle(fontSize: 16.0),
                              )
                            ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          );
        },
      ),
    );
  }
}
