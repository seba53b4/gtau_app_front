import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../constants/theme_constants.dart';
import '../enums/point_type_enum.dart';

Circle? buildCircle(Map<String, dynamic> json, PointType type) {
  if (json.containsKey('geoJSON') && json['geoJSON'] is Map<String, dynamic>) {
    Map<String, dynamic> geoJson = json['geoJSON'];
    List<dynamic> coordenates = geoJson['coordinates'];

    double latitude = coordenates[1];
    double longitude = coordenates[0];
    LatLng latLngCenter = LatLng(latitude, longitude);

    Circle circle;
    if (type == PointType.register) {
      circle = Circle(
          circleId: CircleId('${json['ogcFid']}'),
          center: latLngCenter,
          radius: 1.3,
          strokeWidth: 7,
          consumeTapEvents: true,
          strokeColor: registerDefaultColor,
          fillColor: Colors.grey);
    } else {
      circle = Circle(
          circleId: CircleId('${json['ogcFid']}'),
          center: latLngCenter,
          radius: 2,
          strokeWidth: 2,
          consumeTapEvents: true,
          strokeColor: catchmentDefaultColor,
          fillColor: Colors.black);
    }

    return circle;
  }
  return null;
}
