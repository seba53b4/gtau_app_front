class SectionFeature {
  String type;
  SectionFeatureProperties properties;
  GeometrySection geometry;

  SectionFeature(
      {required this.type, required this.properties, required this.geometry});

  factory SectionFeature.fromJson(Map<String, dynamic> json) {
    return SectionFeature(
      type: json['type'],
      properties: SectionFeatureProperties.fromJson(json['properties']),
      geometry: GeometrySection.fromJson(json['geometry']),
    );
  }
}

class SectionFeatureProperties {
  String tipoSec;
  String tipoTra;
  int gid;
  int elemRed;
  double dim1;
  double dim2;
  double zArriba;
  double zAbajo;
  double longitud;
  double latc;
  double lonc;
  String datoObra;
  int anio;
  String descTramo;
  String descSecci;
  String limpieza;
  dynamic obs;
  int acta;
  dynamic fechaLimp;
  String pend;
  dynamic catastro;
  dynamic inspeccion;
  String tipoInsp;
  dynamic obsLimp;
  String estadoMan;
  String estadoEst;
  dynamic fotografia;

  SectionFeatureProperties({
    required this.tipoSec,
    required this.tipoTra,
    required this.gid,
    required this.elemRed,
    required this.dim1,
    required this.dim2,
    required this.zArriba,
    required this.zAbajo,
    required this.longitud,
    required this.latc,
    required this.lonc,
    required this.datoObra,
    required this.anio,
    required this.descTramo,
    required this.descSecci,
    required this.limpieza,
    required this.obs,
    required this.acta,
    required this.fechaLimp,
    required this.pend,
    required this.catastro,
    required this.inspeccion,
    required this.tipoInsp,
    required this.obsLimp,
    required this.estadoMan,
    required this.estadoEst,
    required this.fotografia,
  });

  factory SectionFeatureProperties.fromJson(Map<String, dynamic> json) {
    return SectionFeatureProperties(
      tipoSec: json['TIPOSEC'],
      tipoTra: json['TIPOTRA'],
      gid: json['GID'],
      elemRed: json['ELEMRED'],
      dim1: json['DIM1'],
      dim2: json['DIM2'],
      zArriba: json['ZARRIBA'],
      zAbajo: json['ZABAJO'],
      longitud: json['LONGITUD'],
      latc: json['LATC'],
      lonc: json['LONC'],
      datoObra: json['DATO_OBRA'],
      anio: json['ANIO'],
      descTramo: json['DESC_TRAMO'],
      descSecci: json['DESC_SECCI'],
      limpieza: json['LIMPIEZA'],
      obs: json['OBS'],
      acta: json['ACTA'],
      fechaLimp: json['FECHA_LIMP'],
      pend: json['PEND(%)'],
      catastro: json['CATASTRO'],
      inspeccion: json['INSPECCION'],
      tipoInsp: json['TIPO_INSP'],
      obsLimp: json['OBS_LIMP'],
      estadoMan: json['ESTADO_MAN'],
      estadoEst: json['ESTADO_EST'],
      fotografia: json['FOTOGRAFIA'],
    );
  }
}

class GeometrySection {
  String type;
  List<List<List<double>>> coordinates;

  GeometrySection({required this.type, required this.coordinates});

  factory GeometrySection.fromJson(Map<String, dynamic> json) {
    return GeometrySection(
      type: json['type'],
      coordinates: List<List<List<double>>>.from(json['coordinates'].map((x) =>
          List<List<double>>.from(
              x.map((y) => List<double>.from(y.map((z) => z.toDouble())))))),
    );
  }
}
