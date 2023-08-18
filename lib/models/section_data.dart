
import 'dart:core';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Section {
  late final int ogcFid;
  late final String? tipoSec;
  late final String? tipoTra;
  late final int? elemRed;
  late final double? dim1;
  late final double? dim2;
  late final double? zArriba;
  late final double? zAbajo;
  late final double? longitud;
  late final double? latC;
  late final double? lonC;
  late final String? datoObra;
  late final DateTime? year;
  late final String? descTramo;
  late final String? descSeccion;
  final Polyline line;

  Section({
    required this.ogcFid,
    required this.line,
    this.tipoSec,
    this.tipoTra,
    this.elemRed,
    this.dim1,
    this.dim2,
    this.zArriba,
    this.zAbajo,
    this.longitud,
    this.latC,
    this.lonC,
    this.datoObra,
    this.year,
    this.descTramo,
    this.descSeccion
  });
}
