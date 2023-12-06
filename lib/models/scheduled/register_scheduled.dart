import 'package:gtau_app_front/models/enums/point_type_enum.dart';
import 'package:gtau_app_front/models/point_data.dart';

import 'common.dart';

class RegisterScheduled extends PointData {
  final String? tipoPto;
  final String? tipoPavimento;
  final String? estadoRegistro;
  final String? cotaTapa;
  final String? profundidad;
  final String? apertura;
  final String? estadoTapa;
  final String? observaciones;
  final String? catastro;
  final bool inspectioned;
  final DateTime? inspectionedDate;
  final String? username;

  RegisterScheduled(
      {this.tipoPto,
      this.tipoPavimento,
      this.estadoRegistro,
      this.cotaTapa,
      this.profundidad,
      this.apertura,
      this.estadoTapa,
      this.observaciones,
      this.catastro,
      required this.inspectioned,
      this.inspectionedDate,
      this.username,
      required super.ogcFid,
      super.type = PointType.register,
      super.point});

  factory RegisterScheduled.fromJson(Map<String, dynamic> json) {
    return RegisterScheduled(
        tipoPto: json['tipo_pto'] as String?,
        tipoPavimento: json['tipo_pavimento'] as String?,
        estadoRegistro: json['estado_registro'] as String?,
        cotaTapa: json['cota_tapa'] as String?,
        profundidad: json['profundidad'] as String?,
        apertura: json['apertura'] as String?,
        estadoTapa: json['estado_tapa'] as String?,
        observaciones: json['observaciones'] as String?,
        catastro: json['catastro'] as String?,
        inspectioned: json['inspectioned'] as bool,
        inspectionedDate: json['inspectioned_date'] != null
            ? DateTime.parse(json['inspectioned_date'] as String)
            : null,
        username: json['username'] as String?,
        ogcFid: json['ogcFid'] as int,
        point: buildCircle(json, PointType.register));
  }
}
