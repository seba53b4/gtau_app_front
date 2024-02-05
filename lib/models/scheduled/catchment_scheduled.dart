import 'package:gtau_app_front/models/enums/point_type_enum.dart';

import '../point_data.dart';
import 'common.dart';

class CatchmentScheduled extends PointDataScheduled {
  final String? tipo;
  final int? idCaptacion;
  final bool? notFound;
  final String? catastro;
  final String? estadoConexion;
  final String? estadoLlamada;
  final String? estadoLosa;
  final String? estadoTabique;
  final String? estadoDeposito;
  final List<String>? tapa1;
  final List<String>? tapa2;
  final String? observaciones;
  final bool inspectioned;
  final DateTime? inspectionedDate;
  final String? username;

  CatchmentScheduled(
      {this.tipo,
      this.idCaptacion,
      this.notFound,
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
      super.ogcFid,
      super.type = PointType.catchment,
      super.point});

  factory CatchmentScheduled.fromJson(
      {required Map<String, dynamic> json, bool isFetch = false}) {
    return CatchmentScheduled(
        ogcFid:
            (json['ogcFid'] is num) ? (json['ogcFid'] as num).toInt() : null,
        tipo: json['tipo'] as String?,
        notFound: json['notFound'] as bool?,
        idCaptacion: json['idCaptacion'] as int?,
        catastro: json['catastro'] as String?,
        estadoConexion: json['estadoConexion'] as String?,
        estadoLlamada: json['estadoLlamada'] as String?,
        estadoLosa: json['estadoLosa'] as String?,
        estadoTabique: json['estadoTabique'] as String?,
        estadoDeposito: json['estadoDeposito'] as String?,
        tapa1: (json['tapa1'] as List<dynamic>?)?.cast<String>(),
        tapa2: (json['tapa2'] as List<dynamic>?)?.cast<String>(),
        observaciones: json['observaciones'] as String?,
        inspectioned: json['inspectioned'] as bool,
        inspectionedDate: json['inspectionedDate'] != null
            ? DateTime.parse(json['inspectionedDate'] as String)
            : null,
        username: json['username'] as String?,
        type: PointType.catchment,
        point: isFetch
            ? null
            : buildCircle(
                json, PointType.catchment, json['notFound'] ?? false));
  }
}
