import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../enums/section_color_enum.dart';

class SectionScheduled {
  final int ogcFid;
  final String tipoTra;
  final double? diametro;
  final double? longitud;
  final String? nivelSedimentacion;
  final bool? observacionAguaArriba;
  final bool? observacionAguaAbajo;
  final String? patologias;
  final String? catastro;
  final String? observaciones;
  final bool? inspectioned;
  final DateTime? inspectionedDate;
  final String? username;
  final Polyline? line;

  SectionScheduled({
    required this.ogcFid,
    required this.tipoTra,
    this.diametro,
    this.longitud,
    this.nivelSedimentacion,
    this.observacionAguaArriba,
    this.observacionAguaAbajo,
    this.patologias,
    this.catastro,
    this.observaciones,
    this.inspectioned,
    this.inspectionedDate,
    this.username,
    this.line,
  });

  factory SectionScheduled.fromJson(Map<String, dynamic> json) {
    return SectionScheduled(
      ogcFid: json['ogcFid'] as int,
      tipoTra: json['tipotra'] as String,
      diametro: json['diametro'] as double?,
      longitud: json['longitud'] as double?,
      nivelSedimentacion: json['nivel_sedimentacion'] as String?,
      observacionAguaArriba: json['observacion_agua_arriba'] as bool?,
      observacionAguaAbajo: json['observacion_agua_abajo'] as bool?,
      patologias: json['patologias'] as String?,
      catastro: json['catastro'] as String?,
      observaciones: json['observaciones'] as String?,
      inspectioned: json['inspectioned'] as bool?,
      inspectionedDate: json['inspectioned_date'] != null
          ? DateTime.parse(json['inspectioned_date'] as String)
          : null,
      username: json['username'] as String?,
      line: _buildPolyline(json, json['tipotra'] as String),
    );
  }

  static Polyline? _buildPolyline(Map<String, dynamic> json, String tipoTra) {
    if (json.containsKey('geoJSON') &&
        json['geoJSON'] is Map<String, dynamic>) {
      Map<String, dynamic> geoJSON = json['geoJSON'];

      if (geoJSON.containsKey('type') &&
          geoJSON['type'] == 'MultiLineString' &&
          geoJSON.containsKey('coordinates') &&
          geoJSON['coordinates'] is List) {
        List<dynamic> multiLineCoordinates = geoJSON['coordinates'];
        List<LatLng> latLngList = [];

        for (var coordinatesList in multiLineCoordinates) {
          for (var coord in coordinatesList) {
            double latitude = coord[1];
            double longitude = coord[0];
            latLngList.add(LatLng(latitude, longitude));
          }
        }

        SectionColor byName = getPolylineColor(tipoTra);
        if (multiLineCoordinates.isNotEmpty) {
          return Polyline(
            polylineId: PolylineId('${json['ogcFid'].toString()}'),
            points: latLngList,
            color: byName.color,
            width: 5,
            consumeTapEvents: true,
          );
        }
      }
    }

    return null;
  }
}

SectionColor getPolylineColor(String tipoTra) {
  try {
    return SectionColor.values.byName(tipoTra.toLowerCase());
  } on ArgumentError {
    return SectionColor.def;
  }
}
