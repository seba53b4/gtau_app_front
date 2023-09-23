import 'dart:core';

import 'package:gtau_app_front/models/point_data.dart';
import 'package:gtau_app_front/models/point_type_enum.dart';

class Register extends PointData {
  late final String? tipo;
  late final double? gid;
  late final int? elemRed;
  late final double? cota;
  late final double? inspeccion;
  late final double? latC;
  late final double? lonC;
  late final String? datoObra;

  Register(
      {required super.ogcFid,
      required super.point,
      this.tipo,
      this.gid,
      this.elemRed,
      this.cota,
      this.inspeccion,
      this.latC,
      this.lonC,
      this.datoObra})
      : super(type: PointType.register);
}
