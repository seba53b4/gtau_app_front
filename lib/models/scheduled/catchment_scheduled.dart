import 'package:gtau_app_front/models/enums/point_type_enum.dart';

import '../point_data.dart';
import 'common.dart';

class CatchmentScheduled extends PointData {
  final String? tipo;
  final String? catastro;
  final String? estadoConexion;
  final String? estadoLlamada;
  final String? estadoLosa;
  final String? estadoTabique;
  final String? estadoDeposito;
  final String? tapa1;
  final String? tapa2;
  final String? observaciones;
  final bool inspectioned;
  final DateTime? inspectionedDate;
  final String? username;

  CatchmentScheduled(
      {this.tipo,
      this.catastro,
      this.estadoConexion,
      this.estadoLlamada,
      this.estadoLosa,
      this.estadoTabique,
      this.estadoDeposito,
      this.tapa1,
      this.tapa2,
      this.observaciones,
      required this.inspectioned,
      this.inspectionedDate,
      this.username,
      required super.ogcFid,
      required super.type,
      super.point});

  factory CatchmentScheduled.fromJson(Map<String, dynamic> json) {
    return CatchmentScheduled(
        ogcFid: json['ogcFid'] as int,
        tipo: json['tipo'] as String?,
        catastro: json['catastro'] as String?,
        estadoConexion: json['estado_conexion'] as String?,
        estadoLlamada: json['estado_llamada'] as String?,
        estadoLosa: json['estado_losa'] as String?,
        estadoTabique: json['estado_tabique'] as String?,
        estadoDeposito: json['estado_deposito'] as String?,
        tapa1: json['tapa1'] as String?,
        tapa2: json['tapa2'] as String?,
        observaciones: json['observaciones'] as String?,
        inspectioned: json['inspectioned'] as bool,
        inspectionedDate: json['inspectioned_date'] != null
            ? DateTime.parse(json['inspectioned_date'] as String)
            : null,
        username: json['username'] as String?,
        type: PointType.catchment,
        point: buildCircle(json, PointType.catchment));
  }
}
