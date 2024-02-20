import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gtau_app_front/models/enums/point_type_enum.dart';

class PointData {
  late final int ogcFid;
  final Circle? point;
  final PointType type;

  PointData({required this.ogcFid, this.point, required this.type});
}

class PointDataScheduled {
  late final int? ogcFid;
  final Circle? point;
  final PointType type;

  PointDataScheduled({required this.ogcFid, this.point, required this.type});
}
