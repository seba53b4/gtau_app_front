import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../constants/theme_constants.dart';
import '../enums/section_color_enum.dart';

class SectionScheduled {
  final int? ogcFid;
  final int? idTramo;
  final bool? notFound;
  final String? tipoTra;
  final double? diametro;
  final double? diametro2;
  final double? longitud;
  final String? nivelSedimentacion;
  final bool? observacionAguaArriba;
  final bool? observacionAguaAbajo;
  final List<String>? patologias;
  final String? catastro;
  final String? observaciones;
  final bool inspectioned;
  final DateTime? inspectionedDate;
  final String? username;
  final Polyline? line;

  SectionScheduled({
    this.diametro2,
    this.idTramo,
    this.ogcFid,
    this.notFound,
    this.tipoTra,
    this.diametro,
    this.longitud,
    this.nivelSedimentacion,
    this.observacionAguaArriba,
    this.observacionAguaAbajo,
    this.patologias,
    this.catastro,
    this.observaciones,
    required this.inspectioned,
    this.inspectionedDate,
    this.username,
    this.line,
  });

  factory SectionScheduled.fromJson(
      {required Map<String, dynamic> json, bool isFetch = false}) {
    return SectionScheduled(
      ogcFid: (json['ogcFid'] is num) ? (json['ogcFid'] as num).toInt() : null,
      idTramo: json['idTramo'] as int?,
      notFound: json['notFound'] as bool?,
      tipoTra: json['tipoTra'] as String?,
      diametro: json['diametro'] as double?,
      diametro2: json['diametro2'] as double?,
      longitud: json['longitud'] as double?,
      nivelSedimentacion: json['nivelSedimentacion'] as String?,
      observacionAguaArriba: json['observacionAguaArriba'] as bool?,
      observacionAguaAbajo: json['observacionAguaAbajo'] as bool?,
      patologias: (json['patologias'] as List<dynamic>?)?.cast<String>(),
      catastro: json['catastro'] as String?,
      observaciones: json['observaciones'] as String?,
      inspectioned: json['inspectioned'] as bool,
      inspectionedDate: json['inspectionedDate'] != null
          ? DateTime.parse(json['inspectionedDate'] as String)
          : null,
      username: json['username'] as String?,
      line: isFetch ? null : _buildPolyline(json, json['tipotra'] as String?),
    );
  }

  static Polyline? _buildPolyline(Map<String, dynamic> json, String? tipoTra) {
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

        //SectionColor byName = getPolylineColor(tipoTra);
        if (multiLineCoordinates.isNotEmpty) {
          return Polyline(
            polylineId: PolylineId('${json['ogcFid'].toString()}'),
            points: latLngList,
            color: scheduledNotInspectionedElement,
            width: 5,
            consumeTapEvents: true,
          );
        }
      }
    }

    return null;
  }
}

SectionColor getPolylineColor(String? tipoTra) {
  try {
    return SectionColor.values.byName(tipoTra!.toLowerCase());
  } on ArgumentError {
    return SectionColor.def;
  }
}
