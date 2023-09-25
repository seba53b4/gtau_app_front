import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/date_utils.dart';
import '../../viewmodels/catchment_viewmodel.dart';
import '../loading_component.dart';
import 'box_container.dart';
import 'common_element_detail.dart';

class CatchmentDetail extends StatelessWidget {
  const CatchmentDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CatchmentViewModel>(
        builder: (context, catchmentViewModel, child) {
      final catchmentDetail = catchmentViewModel.catchmentForDetail;
      final catchmentLoading = catchmentViewModel.isLoading;

      if (catchmentLoading) {
        return const LoadingWidget(heightRatio: 0.8);
      }
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: BoxContainer(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              buildInfoRow("ogcFid", catchmentDetail?.ogcFid.toString()),
              buildInfoRow("gid", catchmentDetail?.gid?.toString()),
              buildInfoRow(
                  "elemred", catchmentDetail?.elemRed?.toStringAsFixed(1)),
              buildInfoRow("Tipo", catchmentDetail?.tipo.toString()),
              buildInfoRow("Tipo Boca", catchmentDetail?.tipoboca.toString()),
              buildInfoRow("latc", catchmentDetail?.latC?.toString()),
              buildInfoRow("lonc", catchmentDetail?.lonC?.toString()),
              buildInfoRow("datoObra", catchmentDetail?.datoObra),
              buildInfoRow("ucrea", catchmentDetail?.ucrea?.toString()),
              buildInfoRow(
                  "fcrea", parseDateTimeOnFormatHour(catchmentDetail?.fcrea)),
              buildInfoRow("uact", catchmentDetail?.uact?.toString()),
              buildInfoRow(
                  "fact", parseDateTimeOnFormatHour(catchmentDetail?.fact)),
              buildInfoMultiRow("idauditori", catchmentDetail?.idauditori),
            ],
          ),
        ),
      );
    });
  }
}
