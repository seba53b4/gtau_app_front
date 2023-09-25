import 'package:flutter/material.dart';
import 'package:gtau_app_front/viewmodels/section_viewmodel.dart';
import 'package:provider/provider.dart';

import '../loading_component.dart';

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
        child: SizedBox(
          height: 560,
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              _buildInfoRow("ogcFid", sectionDetail?.ogcFid.toString()),
              _buildInfoRow("zabajo", sectionDetail?.zAbajo?.toString()),
              _buildInfoRow("longitud", sectionDetail?.longitud?.toString()),
              _buildInfoRow("latc", sectionDetail?.latC?.toString()),
              _buildInfoRow("lonc", sectionDetail?.lonC?.toString()),
              _buildInfoRow(
                  "año",
                  sectionDetail?.year != null
                      ? sectionDetail?.year!.year.toString()
                      : null),
              _buildInfoRow("gid", sectionDetail?.gid?.toString()),
              _buildInfoRow(
                  "elemred", sectionDetail?.elemRed?.toStringAsFixed(1)),
              _buildInfoRow("dim1", sectionDetail?.dim1?.toStringAsFixed(1)),
              _buildInfoRow("dim2", sectionDetail?.dim2?.toStringAsFixed(1)),
              _buildInfoRow("zarriba", sectionDetail?.zArriba?.toString()),
              _buildInfoRow("tiposec", sectionDetail?.tipoSec?.toString()),
              _buildInfoRow("tipotra", sectionDetail?.tipoTra?.toString()),
              _buildInfoRow("datoObra", sectionDetail?.datoObra),
              _buildInfoRow("descSecci", sectionDetail?.descSeccion),
              _buildInfoRow("descTramo", sectionDetail?.descTramo),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$label: ",
              style: const TextStyle(
                  color: Color.fromRGBO(14, 45, 9, 1),
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
            Text(value ?? "Sin Datos", style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
