
import 'dart:core';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Section {
  late final int gid;
  late final String? typeSec;
  late final String? typeTra;
  late final int? elemRed;
  late final double? dim1;
  late final double? dim2;
  late final double? zUp;
  late final double? zDown;
  late final double? longitude;
  late final double latC;
  late final double lonC;
  late final String? datoObra;
  late final DateTime? year;
  late final String? descTramo;
  late final String? descSeccion;
  final Polyline line;

  Section({
    // required this.gid,
    required this.line
  });
}
