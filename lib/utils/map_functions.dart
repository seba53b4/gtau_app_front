import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../constants/theme_constants.dart';
import 'common_utils.dart';

double calculateDistance(LatLng point1, LatLng point2) {
  final double dx = point1.latitude - point2.latitude;
  final double dy = point1.longitude - point2.longitude;
  final double distance = sqrt(dx * dx + dy * dy);
  return distance;
}

List<LatLng> getLargePolylineOnSection(List<LatLng> points) {
  List<LatLng> ret = [];
  double maxLength = 0;
  for (int i = 0; i < points.length - 1; i++) {
    final dist = calculateDistance(points[i], points[i + 1]);
    if (dist > maxLength) {
      maxLength = dist;
      ret.clear();
      ret.add(points[i]);
      ret.add(points[i + 1]);
    }
  }

  return ret;
}

Set<Polyline> polylineArrows(List<LatLng> points, PolylineId polylineId) {
  Set<Polyline> ret = {};
  const int arrowWidth = 3;

  try {
    LatLng init, end;

    if (points.length == 2) {
      end = points.first;
      init = points.last;
    } else {
      List<LatLng> pointsOfArrow = getLargePolylineOnSection(points);
      init = pointsOfArrow.last;
      end = pointsOfArrow.first;
    }

    // Calcula el punto medio de la línea principal
    LatLng midPoint = LatLng(
      (init.latitude + end.latitude) / 2,
      (init.longitude + end.longitude) / 2,
    );

    // Calcula el ángulo entre los puntos init y end
    double angleOfPolylineRadians =
        atan2(end.latitude - init.latitude, end.longitude - init.longitude);

    double angle = 20 * (pi / 180); // Ángulo de los vertices según la polylinea
    double arrowLength =
        0.00002225; //0.00001225; // Largo de los vértices de la flecha

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
  } catch (error) {
    printOnDebug(error);
  }

  return ret;
}

LatLng getRandomPoint(List<LatLng> points) {
  if (points.isEmpty) {
    return const LatLng(-34.88773, -56.13955);
  }

  final randomIndex = Random().nextInt(points.length);
  return points[randomIndex];
}

LatLng? getRandomPointOfMap(Set<Polyline> polylines, Set<Circle> circles) {
  List<LatLng> allPoints = [];
  int numberOfElements = 2;

  // Agregan de las polilíneas
  for (var polyline in polylines.take(numberOfElements)) {
    allPoints.addAll(polyline.points);
  }

  // Agregan de los círculos
  for (var circle in circles.take(numberOfElements)) {
    allPoints.add(circle.center);
  }

  return getRandomPoint(allPoints);
}

String customMapStyle = '''
[
  {
    "featureType": "administrative",
    "elementType": "geometry",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "poi",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "transit",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  }
]
''';
