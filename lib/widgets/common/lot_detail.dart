import 'package:flutter/material.dart';
import 'package:gtau_app_front/viewmodels/lot_viewmodel.dart';
import 'package:provider/provider.dart';

import '../loading_component.dart';
import 'common_element_detail.dart';

class LotDetail extends StatelessWidget {
  const LotDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LotViewModel>(builder: (context, lotViewModel, child) {
      final lotDetail = lotViewModel.lotForDetail;
      final sectionLoading = lotViewModel.isLoading;
      const String DEFAULT = "";

      if (sectionLoading) {
        return const LoadingWidget(heightRatio: 0.8);
      }
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            buildInfoRow("ogcFid", lotDetail?.ogcFid.toString()),
            buildInfoRow("gid", (lotDetail?.gid ?? DEFAULT).toString()),
            buildInfoRow("padron", (lotDetail?.padron ?? DEFAULT).toString()),
            buildInfoRow("areatot", (lotDetail?.areatot ?? DEFAULT).toString()),
            buildInfoRow("areacat", (lotDetail?.areacat ?? DEFAULT).toString()),
            buildInfoRow("ph", (lotDetail?.ph ?? "").toString()),
            buildInfoRow(
                "imponible", (lotDetail?.imponible ?? DEFAULT).toString()),
            buildInfoRow(
                "carpetaPh", (lotDetail?.carpetaPh ?? DEFAULT).toString()),
            buildInfoRow(
                "categoria", (lotDetail?.categoria ?? DEFAULT).toString()),
            buildInfoRow("subCategoria",
                (lotDetail?.subCategoria ?? DEFAULT).toString()),
            buildInfoMultiRow(
                "areaDifer", (lotDetail?.areaDifer ?? DEFAULT).toString()),
            buildInfoRow(
                "cortado_rn", (lotDetail?.cortado_rn ?? DEFAULT).toString()),
            buildInfoRow(
                "rn_area_di", (lotDetail?.rn_area_di ?? DEFAULT).toString()),
            buildInfoRow("rgs", (lotDetail?.rgs ?? DEFAULT).toString()),
            buildInfoRow("retiro", (lotDetail?.retiro ?? DEFAULT).toString()),
            buildInfoRow("galibo", (lotDetail?.galibo ?? DEFAULT).toString()),
            buildInfoRow("altura", (lotDetail?.altura ?? DEFAULT).toString()),
            buildInfoRow("fos", (lotDetail?.fos ?? DEFAULT).toString()),
            buildInfoRow("usopre", (lotDetail?.usopre ?? DEFAULT).toString()),
            buildInfoRow("planesp", (lotDetail?.planesp ?? DEFAULT).toString()),
            buildInfoRow(
                "planparcia", (lotDetail?.planparcia ?? DEFAULT).toString()),
            buildInfoRow("promo", (lotDetail?.promo ?? DEFAULT).toString()),
            buildInfoRow("fis", (lotDetail?.fis ?? DEFAULT).toString()),
            buildInfoRow(
                "nom_trans", (lotDetail?.nom_trans ?? DEFAULT).toString()),
            buildInfoRow(
                "tipo_trans", (lotDetail?.tipo_trans ?? DEFAULT).toString()),
            buildInfoRow(
                "estado_tra", (lotDetail?.estado_tra ?? DEFAULT).toString()),
          ],
        ),
      );
    });
  }
}
