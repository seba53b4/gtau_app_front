import 'package:gtau_app_front/models/enums/point_type_enum.dart';
import 'package:gtau_app_front/models/point_data.dart';

import 'common.dart';

class RegisterScheduled extends PointDataScheduled {
  final String? tipoPto;
  final int? idRegistro;
  final bool? notFound;
  final String? tipoPavimento;
  final String? estadoRegistro;
  final String? cotaTapa;
  final String? profundidad;
  final String? apertura;
  final List<String>? estadoTapa;
  final String? observaciones;
  final String? catastro;
  final bool inspectioned;
  final DateTime? inspectionedDate;
  final String? username;

  RegisterScheduled(
      {this.tipoPto,
      this.notFound,
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
      this.idRegistro,
      super.point});

  factory RegisterScheduled.fromJson(
      {required Map<String, dynamic> json, bool isFetch = false}) {
    return RegisterScheduled(
        tipoPto: json['tipo'] as String?,
        idRegistro: json['idRegistro'] as int?,
        notFound: json['notFound'] as bool?,
        tipoPavimento: json['tipoPavimento'] as String?,
        estadoRegistro: json['estadoRegistro'] as String?,
        cotaTapa: json['cotaTapa'] as String?,
        profundidad: json['profundidad'] as String?,
        apertura: json['apertura'] as String?,
        estadoTapa: (json['estadoTapa'] as List<dynamic>?)?.cast<String>(),
        observaciones: json['observaciones'] as String?,
        catastro: json['catastro'] as String?,
        inspectioned: json['inspectioned'] as bool,
        inspectionedDate: json['inspectionedDate'] != null
            ? DateTime.parse(json['inspectionedDate'] as String)
            : null,
        username: json['username'] as String?,
        ogcFid: json['ogcFid'] as int?,
        point: isFetch
            ? null
            : buildCircle(json, PointType.register, json['notFound'] ?? false));
  }
}
