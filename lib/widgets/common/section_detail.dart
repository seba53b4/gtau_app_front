import 'package:flutter/material.dart';
import 'package:gtau_app_front/viewmodels/section_viewmodel.dart';
import 'package:gtau_app_front/widgets/common/box_container.dart';
import 'package:provider/provider.dart';

import '../loading_component.dart';
import 'common_element_detail.dart';

class SectionDetail extends StatelessWidget {
  const SectionDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SectionViewModel>(
        builder: (context, sectionViewModel, child) {
      final sectionDetail = sectionViewModel.sectionForDetail;
      final sectionLoading = sectionViewModel.isLoading;

      if (sectionLoading) {
        return const LoadingWidget(heightRatio: 0.8);
      }
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: BoxContainer(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              buildInfoRow("ogcFid", sectionDetail?.ogcFid.toString()),
              buildInfoRow("zabajo", sectionDetail?.zAbajo?.toString()),
              buildInfoRow("longitud", sectionDetail?.longitud?.toString()),
              buildInfoRow("latc", sectionDetail?.latC?.toString()),
              buildInfoRow("lonc", sectionDetail?.lonC?.toString()),
              buildInfoRow(
                  "año",
                  sectionDetail?.year != null
                      ? sectionDetail?.year!.year.toString()
                      : null),
              buildInfoRow("gid", sectionDetail?.gid?.toString()),
              buildInfoRow(
                  "elemred", sectionDetail?.elemRed?.toStringAsFixed(1)),
              buildInfoRow("dim1", sectionDetail?.dim1?.toStringAsFixed(1)),
              buildInfoRow("dim2", sectionDetail?.dim2?.toStringAsFixed(1)),
              buildInfoRow("zarriba", sectionDetail?.zArriba?.toString()),
              buildInfoRow("tiposec", sectionDetail?.tipoSec?.toString()),
              buildInfoRow("tipotra", sectionDetail?.tipoTra?.toString()),
              buildInfoRow("datoObra", sectionDetail?.datoObra),
              buildInfoRow("descSecci", sectionDetail?.descSeccion),
              buildInfoRow("descTramo", sectionDetail?.descTramo),
            ],
          ),
        ),
      );
    });
  }
}
