import 'dart:core';

import 'package:gtau_app_front/models/point_data.dart';
import 'package:gtau_app_front/models/point_type_enum.dart';

class Catchment extends PointData {
  late final double? gid;
  late final int? elemRed;
  late final String? tipo;
  late final int? tipoboca;
  late final double? latC;
  late final double? lonC;
  late final String? datoObra;
  late final String? ucrea;
  late final DateTime? fcrea;
  late final String? uact;
  late final DateTime? fact;
  late final String? idauditori;

  Catchment(
      {required super.ogcFid,
      this.gid,
      this.elemRed,
      required this.tipo,
      required this.tipoboca,
      this.latC,
      this.lonC,
      this.datoObra,
      this.fact,
      this.fcrea,
      this.idauditori,
      this.uact,
      this.ucrea,
      required super.point})
      : super(type: PointType.catchment);
}
