import 'package:gtau_app_front/models/shape_load/common_shape_load.dart';

class RegisterFeature {
  String type;
  RegisterFeatureProperties properties;
  GeometryPoint? geometry;

  RegisterFeature(
      {required this.type, required this.properties, this.geometry});

  factory RegisterFeature.fromJson(Map<String, dynamic> json) {
    return RegisterFeature(
      type: json['type'],
      properties: RegisterFeatureProperties.fromJson(json['properties']),
      geometry: json['geometry'] != null
          ? GeometryPoint.fromJson(json['geometry'])
          : null,
    );
  }
}

class RegisterFeatureProperties {
  String tipoPto;
  dynamic gid;
  dynamic elemRed;
  dynamic cota;
  dynamic inspeccion;
  dynamic latc;
  dynamic lonc;
  dynamic datoObra;
  dynamic descripcion;
  dynamic sig;
  dynamic estadoEst;
  dynamic czs;
  dynamic obs;
  dynamic fotografia;

  RegisterFeatureProperties({
    required this.tipoPto,
    required this.gid,
    required this.elemRed,
    required this.cota,
    required this.inspeccion,
    required this.latc,
    required this.lonc,
    required this.datoObra,
    required this.descripcion,
    required this.sig,
    required this.estadoEst,
    required this.czs,
    required this.obs,
    required this.fotografia,
  });

  factory RegisterFeatureProperties.fromJson(Map<String, dynamic> json) {
    return RegisterFeatureProperties(
      tipoPto: json['TIPO_PTO'],
      gid: json['GID'],
      elemRed: json['ELEM_RED'],
      cota: json['COTA'],
      inspeccion: json['INSPECCION'],
      latc: json['LATC'],
      lonc: json['LONC'],
      datoObra: json['DATO_OBRA'],
      descripcion: json['DESCRIPCIO'],
      sig: json['SIG'],
      estadoEst: json['ESTADO_EST'],
      czs: json['CZs'],
      obs: json['OBS'],
      fotografia: json['FOTOGRAFIA'],
    );
  }
}
