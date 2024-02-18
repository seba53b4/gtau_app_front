class LotFeature {
  String type;
  LotFeatureProperties properties;
  GeometryLot geometry;

  LotFeature(
      {required this.type, required this.properties, required this.geometry});

  factory LotFeature.fromJson(Map<String, dynamic> json) {
    return LotFeature(
      type: json['type'],
      properties: LotFeatureProperties.fromJson(json['properties']),
      geometry: GeometryLot.fromJson(json['geometry']),
    );
  }
}

class LotFeatureProperties {
  double gid;
  int padron;
  double areaTot;
  double areaCat;
  int ph;
  dynamic imponible;
  dynamic carpetaPh;
  String categoria;
  String subCatego;
  String areaDifer;
  String cortadoRn;
  dynamic rnAreaDi;
  String rgs;
  String retiro;
  dynamic galibo;
  String altura;
  String fos;
  String usopre;
  dynamic planesp;
  dynamic planparcia;
  dynamic promo;
  String fis;
  dynamic nomTrans;
  dynamic tipoTrans;
  dynamic estadoTra;

  LotFeatureProperties({
    required this.gid,
    required this.padron,
    required this.areaTot,
    required this.areaCat,
    required this.ph,
    required this.imponible,
    required this.carpetaPh,
    required this.categoria,
    required this.subCatego,
    required this.areaDifer,
    required this.cortadoRn,
    required this.rnAreaDi,
    required this.rgs,
    required this.retiro,
    required this.galibo,
    required this.altura,
    required this.fos,
    required this.usopre,
    required this.planesp,
    required this.planparcia,
    required this.promo,
    required this.fis,
    required this.nomTrans,
    required this.tipoTrans,
    required this.estadoTra,
  });

  factory LotFeatureProperties.fromJson(Map<String, dynamic> json) {
    return LotFeatureProperties(
      gid: json['GID'],
      padron: json['PADRON'],
      areaTot: json['AREATOT'],
      areaCat: json['AREACAT'],
      ph: json['PH'],
      imponible: json['IMPONIBLE'],
      carpetaPh: json['CARPETA_PH'],
      categoria: json['CATEGORIA'],
      subCatego: json['SUB_CATEGO'],
      areaDifer: json['AREA_DIFER'],
      cortadoRn: json['CORTADO_RN'],
      rnAreaDi: json['RN_AREA_DI'],
      rgs: json['RGS'],
      retiro: json['RETIRO'],
      galibo: json['GALIBO'],
      altura: json['ALTURA'],
      fos: json['FOS'],
      usopre: json['USOPRE'],
      planesp: json['PLANESP'],
      planparcia: json['PLANPARCIA'],
      promo: json['PROMO'],
      fis: json['FIS'],
      nomTrans: json['NOM_TRANS'],
      tipoTrans: json['TIPO_TRANS'],
      estadoTra: json['ESTADO_TRA'],
    );
  }
}

class GeometryLot {
  String type;
  List<List<List<List<double>>>> coordinates;

  GeometryLot({required this.type, required this.coordinates});

  factory GeometryLot.fromJson(Map<String, dynamic> json) {
    return GeometryLot(
      type: json['type'],
      coordinates: List<List<List<List<double>>>>.from(json['coordinates'].map(
          (x) => List<List<List<double>>>.from(x.map((y) =>
              List<List<double>>.from(y.map(
                  (z) => List<double>.from(z.map((w) => w.toDouble())))))))),
    );
  }
}
