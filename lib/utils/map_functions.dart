import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


Set<Polyline> polylineArrows(LatLng init, LatLng end, PolylineId polylineId) {
  Set<Polyline> ret = {};

  // Calcula el punto medio de la línea principal
  LatLng midPoint = LatLng(
    (init.latitude + end.latitude) / 2,
    (init.longitude + end.longitude) / 2,
  );

  // Calcula el ángulo entre los puntos init y end
  double angleRadians = atan2(end.latitude - init.latitude, end.longitude - init.longitude);


  double angle30 = 15 * (pi / 180);
  double arrowLength = 0.00003125;
  LatLng sidePoint1 = LatLng(
    midPoint.latitude + sin(angleRadians + angle30) * arrowLength,
    midPoint.longitude + cos(angleRadians + angle30) * arrowLength,
  );
  LatLng sidePoint2 = LatLng(
    midPoint.latitude + sin(angleRadians - angle30) * arrowLength,
    midPoint.longitude + cos(angleRadians - angle30) * arrowLength,
  );

  ret.add(Polyline(
    polylineId: PolylineId((int.parse(polylineId.value) / 2).toString() + "_1"),
    color: Colors.lightBlue,
    width: 5,
    points: [sidePoint1, midPoint],
  ));

  ret.add(Polyline(
    polylineId: PolylineId((int.parse(polylineId.value) / 2).toString() + "_2"),
    color: Colors.lightBlue,
    width: 5,
    points: [midPoint, sidePoint2],
  ));

  return ret;
}