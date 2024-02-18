class GeometryPoint {
  String type;
  List<double> coordinates;

  GeometryPoint({required this.type, required this.coordinates});

  factory GeometryPoint.fromJson(Map<String, dynamic> json) {
    return GeometryPoint(
      type: json['type'],
      coordinates:
          List<double>.from(json['coordinates'].map((x) => x.toDouble())),
    );
  }
}
