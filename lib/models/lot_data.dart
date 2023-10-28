import 'dart:core';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gtau_app_front/models/enums/point_type_enum.dart';
import 'package:gtau_app_front/models/point_data.dart';

class Lot {
  late final int ogcFid;
  late final double? gid;
  late final double? padron;
  late final double? areatot;
  late final double? areacat;
  late final double? ph;
  late final String? imponible;
  late final double? carpetaPh;
  late final String? categoria;
  late final String? subCategoria;
  late final String? areaDifer;
  late final String? cortado_rn;
  late final String? rn_area_di;
  late final String? rgs;
  late final String? retiro;
  late final String? galibo;
  late final String? altura;
  late final String? fos;
  late final String? usopre;
  late final String? planesp;
  late final String? planparcia;
  late final String? promo;
  late final String? fis;
  late final String? nom_trans;
  late final String? tipo_trans;
  late final String? estado_tra;
  late final Polyline? polyline;

  Lot(
      {required this.ogcFid,
      this.gid,
      this.padron,
      this.areatot,
      this.areacat,
      this.ph,
      this.imponible,
      this.carpetaPh,
      this.categoria,
      this.subCategoria,
      this.areaDifer,
      this.cortado_rn,
      this.rn_area_di,
      this.rgs,
      this.retiro,
      this.galibo,
      this.altura,
      this.fos,
      this.usopre,
      this.planesp,
      this.planparcia,
      this.promo,
      this.fis,
      this.nom_trans,
      this.tipo_trans,
      this.estado_tra,
      this.polyline});
}
