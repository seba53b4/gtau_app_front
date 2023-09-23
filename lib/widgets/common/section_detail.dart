import 'package:flutter/material.dart';
import 'package:gtau_app_front/viewmodels/section_viewmodel.dart';
import 'package:provider/provider.dart';

class SectionDetail extends StatefulWidget {
  const SectionDetail({Key? key}) : super(key: key);

  @override
  State<SectionDetail> createState() => _SectionDetailState();
}

class _SectionDetailState extends State<SectionDetail> {
  @override
  void initState() {
    super.initState();
    //_fetchSectionDetail();
  }

  //
  // Future<void> _fetchSectionDetail() async {
  //   if (widget.sectionId != null) {
  //     final token = context.read<UserProvider>().getToken;
  //     await fetchSectionById(token!, widget.sectionId!);
  //   }
  // }
  //
  // Future<Section?> fetchSectionById(String token, int sectionId) async {
  //   final sectionViewModel =
  //       Provider.of<SectionViewModel>(context, listen: false);
  //   return await sectionViewModel.fetchSectionById(token, sectionId);
  // }

  @override
  Widget build(BuildContext context) {
    return Consumer<SectionViewModel>(
        builder: (context, sectionViewModel, child) {
      final sectionDetail = sectionViewModel.sectionForDetail;

      return sectionDetail != null
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.start,
                children: [
                  _buildInfoRow("ogcFid", sectionDetail.ogcFid.toString()),
                  _buildInfoRow("zabajo", sectionDetail.zAbajo?.toString()),
                  _buildInfoRow("longitud", sectionDetail.longitud?.toString()),
                  _buildInfoRow("latc", sectionDetail.latC?.toString()),
                  _buildInfoRow("lonc", sectionDetail.lonC?.toString()),
                  _buildInfoRow(
                      "año",
                      sectionDetail.year != null
                          ? sectionDetail.year!.year.toString()
                          : null),
                  _buildInfoRow("gid", sectionDetail.gid?.toString()),
                  _buildInfoRow(
                      "elemred", sectionDetail.elemRed?.toStringAsFixed(1)),
                  _buildInfoRow("dim1", sectionDetail.dim1?.toStringAsFixed(1)),
                  _buildInfoRow("dim2", sectionDetail.dim2?.toStringAsFixed(1)),
                  _buildInfoRow("zarriba", sectionDetail.zArriba?.toString()),
                  _buildInfoRow("tiposec", sectionDetail.tipoSec?.toString()),
                  _buildInfoRow("tipotra", sectionDetail.tipoTra?.toString()),
                  _buildInfoRow("datoObra", sectionDetail.datoObra),
                  _buildInfoRow("descSecci", sectionDetail.descSeccion),
                  _buildInfoRow("descTramo", sectionDetail.descTramo),
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
}
