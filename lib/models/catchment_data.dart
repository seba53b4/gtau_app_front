import 'dart:core';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class Catchment {
  late final int ogcFid;
  late final double? gid;
  late final int? elemRed;
  late final String? tipo;
  late final String? tipoboca;
  late final double? latC;
  late final double? lonC;
  late final String? datoObra;
  final Circle point;

  Catchment(
      {required this.ogcFid,
      this.gid,
      this.elemRed,
      required this.tipo,
      required this.tipoboca,
      this.latC,
      this.lonC,
      this.datoObra,
      required this.point});
}
