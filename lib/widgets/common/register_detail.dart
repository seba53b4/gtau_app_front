import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/register_viewmodel.dart';
import '../loading_component.dart';

class RegisterDetail extends StatelessWidget {
  const RegisterDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<RegisterViewModel>(
        builder: (context, registerViewModel, child) {
      final registerDetail = registerViewModel.registerForDetail;
      final registerLoading = registerViewModel.isLoading;

      if (registerLoading) {
        return const LoadingWidget();
      }
      return registerDetail != null
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.start,
                children: [
                  _buildInfoRow("ogcFid", registerDetail.ogcFid.toString()),
                  _buildInfoRow("tipo", registerDetail.tipo.toString()),
                  _buildInfoRow("gid", registerDetail.gid?.toString()),
                  _buildInfoRow(
                      "elemred", registerDetail.elemRed?.toStringAsFixed(1)),
                  _buildInfoRow("cota", registerDetail.cota?.toString()),
                  _buildInfoRow(
                      "inspección", registerDetail.inspeccion?.toString()),
                  _buildInfoRow("latc", registerDetail.latC?.toString()),
                  _buildInfoRow("lonc", registerDetail.lonC?.toString()),
                  _buildInfoRow("datoObra", registerDetail.datoObra),
                  _buildInfoMultiRow("descripción", registerDetail.descripcion),
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
