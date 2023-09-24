import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/date_utils.dart';
import '../../viewmodels/catchment_viewmodel.dart';
import '../loading_component.dart';

class CatchmentDetail extends StatelessWidget {
  const CatchmentDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CatchmentViewModel>(
        builder: (context, catchmentViewModel, child) {
      final catchmentDetail = catchmentViewModel.catchmentForDetail;
      final catchmentLoading = catchmentViewModel.isLoading;

      if (catchmentLoading) {
        return const LoadingWidget();
      }
      return catchmentDetail != null
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.start,
                children: [
                  _buildInfoRow("ogcFid", catchmentDetail.ogcFid.toString()),
                  _buildInfoRow("gid", catchmentDetail.gid?.toString()),
                  _buildInfoRow(
                      "elemred", catchmentDetail.elemRed?.toStringAsFixed(1)),
                  _buildInfoRow("Tipo", catchmentDetail.tipo.toString()),
                  _buildInfoRow(
                      "Tipo Boca", catchmentDetail.tipoboca.toString()),
                  _buildInfoRow("latc", catchmentDetail.latC?.toString()),
                  _buildInfoRow("lonc", catchmentDetail.lonC?.toString()),
                  _buildInfoRow("datoObra", catchmentDetail.datoObra),
                  _buildInfoRow("ucrea", catchmentDetail.ucrea?.toString()),
                  _buildInfoRow("fcrea",
                      parseDateTimeOnFormatHour(catchmentDetail.fcrea)),
                  _buildInfoRow("uact", catchmentDetail.uact?.toString()),
                  _buildInfoRow(
                      "fact", parseDateTimeOnFormatHour(catchmentDetail.fact)),
                  _buildInfoMultiRow("idauditori", catchmentDetail.idauditori),
                ],
              ),
            )
          : Text("no data por aca");
    });
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(value ?? "Sin Datos", style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildInfoMultiRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            value ?? "Sin Datos",
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
