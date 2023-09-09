import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


Set<Polyline> polylineArrows(List<LatLng> points, PolylineId polylineId) {

  Set<Polyline> ret = {};
  const Color arrowColor = Colors.lightBlue;
  const int arrowWidth = 3;
  
  try{
    LatLng init, end;
    switch (points.length) {
      case 2:
        init = points.first;
        end = points.last;
      case 3:
        init = points.elementAt(1);
        end = points.elementAt(2);
      default:
        init = points.elementAt(2);
        end = points.elementAt(3);
    }

    // Calcula el punto medio de la línea principal
    LatLng midPoint = LatLng(
      (init.latitude + end.latitude) / 2,
      (init.longitude + end.longitude) / 2,
    );

    // Calcula el ángulo entre los puntos init y end
    double angleOfPolylineRadians = atan2(end.latitude - init.latitude, end.longitude - init.longitude);


    double angle = 20 * (pi / 180); // Ángulo de los vertices según la polylinea
    double arrowLength = 0.00001225; // Largo de los vértices de la flecha

    LatLng sidePoint1 = LatLng(
      midPoint.latitude + sin(angleOfPolylineRadians + angle) * arrowLength,
      midPoint.longitude + cos(angleOfPolylineRadians + angle) * arrowLength,
    );
    LatLng sidePoint2 = LatLng(
      midPoint.latitude + sin(angleOfPolylineRadians - angle) * arrowLength,
      midPoint.longitude + cos(angleOfPolylineRadians - angle) * arrowLength,
    );

    ret.add(Polyline(
      polylineId: PolylineId("${int.parse(polylineId.value) / 2}_1"),
      color: arrowColor,
      width: arrowWidth,
      points: [sidePoint1, midPoint],
    ));

    ret.add(Polyline(
      polylineId: PolylineId("${int.parse(polylineId.value) / 2}_2"),
      color: arrowColor,
      width: 3,
      points: [midPoint, sidePoint2],
    ));
  } catch(error) {
    if (kDebugMode) {
      print(error);
    }
  }

  return ret;
}