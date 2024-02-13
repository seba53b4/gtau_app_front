import 'common_shape_load.dart';

class CatchmentFeature {
  String type;
  CatchmentFeatureProperties properties;
  GeometryPoint geometry;

  CatchmentFeature(
      {required this.type, required this.properties, required this.geometry});

  factory CatchmentFeature.fromJson(Map<String, dynamic> json) {
    return CatchmentFeature(
      type: json['type'],
      properties: CatchmentFeatureProperties.fromJson(json['properties']),
      geometry: GeometryPoint.fromJson(json['geometry']),
    );
  }
}

class CatchmentFeatureProperties {
  int gid;
  int elemRed;
  String tipo;
  int tipoBoca;
  double latc;
  double lonc;
  String datoObra;
  String ucrea;
  String fcrea;
  String uact;
  String fact;
  String idauditori;
  dynamic fecha;
  dynamic estadoCnx;
  dynamic estadoEst;
  dynamic estadoMan;
  dynamic obs;
  dynamic catastro;
  dynamic fotografia;

  CatchmentFeatureProperties({
    required this.gid,
    required this.elemRed,
    required this.tipo,
    required this.tipoBoca,
    required this.latc,
    required this.lonc,
    required this.datoObra,
    required this.ucrea,
    required this.fcrea,
    required this.uact,
    required this.fact,
    required this.idauditori,
    required this.fecha,
    required this.estadoCnx,
    required this.estadoEst,
    required this.estadoMan,
    required this.obs,
    required this.catastro,
    required this.fotografia,
  });

  factory CatchmentFeatureProperties.fromJson(Map<String, dynamic> json) {
    return CatchmentFeatureProperties(
      gid: json['GID'],
      elemRed: json['ELEM_RED'],
      tipo: json['TIPO'],
      tipoBoca: json['TIPOBOCA'],
      latc: json['LATC'],
      lonc: json['LONC'],
      datoObra: json['DATO_OBRA'],
      ucrea: json['UCREA'],
      fcrea: json['FCREA'],
      uact: json['UACT'],
      fact: json['FACT'],
      idauditori: json['IDAUDITORI'],
      fecha: json['FECHA'],
      estadoCnx: json['ESTADO CNX'],
      estadoEst: json['ESTADO EST'],
      estadoMan: json['ESTADO MAN'],
      obs: json['OBS'],
      catastro: json['CATASTRO'],
      fotografia: json['FOTOGRAFIA'],
    );
  }
}
