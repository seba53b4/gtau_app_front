import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/register_viewmodel.dart';
import '../loading_component.dart';
import 'common_element_detail.dart';

class RegisterDetail extends StatelessWidget {
  const RegisterDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<RegisterViewModel>(
        builder: (context, registerViewModel, child) {
      final registerDetail = registerViewModel.registerForDetail;
      final registerLoading = registerViewModel.isLoading;

      if (registerLoading) {
        return const LoadingWidget(heightRatio: 0.8);
      }
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            buildInfoRow("ogcFid", registerDetail?.ogcFid.toString()),
            buildInfoRow("tipo", registerDetail?.tipo.toString()),
            buildInfoRow("gid", registerDetail?.gid?.toString()),
            buildInfoRow(
                "elemred", registerDetail?.elemRed?.toStringAsFixed(1)),
            buildInfoRow("cota", registerDetail?.cota?.toString()),
            buildInfoRow("inspección", registerDetail?.inspeccion?.toString()),
            buildInfoRow("latc", registerDetail?.latC?.toString()),
            buildInfoRow("lonc", registerDetail?.lonC?.toString()),
            buildInfoRow("datoObra", registerDetail?.datoObra),
            buildInfoMultiRow("descripción", registerDetail?.descripcion),
          ],
        ),
      );
    });
  }
}
