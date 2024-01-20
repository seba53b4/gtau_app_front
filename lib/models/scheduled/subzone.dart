import 'dart:core';
import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../constants/theme_constants.dart';

class ScheduledSubZone {
  late int? id;
  late String? nombre;
  late String? cuenca;
  late String? area;
  late List<Polyline> polylines;

  ScheduledSubZone({
    this.id,
    this.nombre,
    this.cuenca,
    this.area,
    List<Polyline>? polylines,
  }) : polylines = polylines ?? [];

  factory ScheduledSubZone.fromJson({required Map<String, dynamic> feature}) {
    List<Polyline> polylines = parseFeatures(feature);

    return ScheduledSubZone(
      id: feature['id'] as int?,
      nombre: feature['nombre'] as String?,
      cuenca: feature['cuenca'] as String?,
      area: feature['area'] as String?,
      polylines: polylines,
    );
  }

  static List<Polyline> parseFeatures(Map<String, dynamic> feature) {
    List<Polyline> polylines = [];

    final geometry = feature['geometry'];
    final type = geometry['type'];
    List<dynamic> coordinates = geometry['coordinates'];
    coordinates = coordinates.first;

    if (type == 'MultiPolygon') {
      List<LatLng> latLngList = [];
      for (var coordinatesList in coordinates) {
        for (var coord in coordinatesList) {
          double latitude = coord[1];
          double longitude = coord[0];
          latLngList.add(LatLng(latitude, longitude));
        }
      }

      polylines.add(Polyline(
          points: latLngList,
          zIndex: -1,
          color: zoneColor,
          width: 5,
          polylineId: PolylineId(Random().nextInt(10001).toString())));
    }

    return polylines;
  }
}
