import 'package:gtau_app_front/models/scheduled/subzone.dart';

class ScheduledZone {
  late int? id;
  late String? name;
  late List<ScheduledSubZone>? subzones;

  ScheduledZone({
    this.id,
    this.name,
    this.subzones,
  });

  factory ScheduledZone.fromJson({required Map<String, dynamic> json}) {
    // Crear una instancia de ScheduledZone a partir de los datos del JSON
    final zone = ScheduledZone(
      id: json['id'] as int?,
      name: json['name'] as String?,
    );

    // Verificar si hay datos en la clave 'features' para las subzonas
    if (json.containsKey('features')) {
      // Obtener la lista de subzonas desde 'features'
      final List<dynamic> features = json['features'];

      // Convertir cada feature a una instancia de ScheduledSubZone y agregarla a la lista de subzonas
      zone.subzones = features
          .map((feature) => ScheduledSubZone.fromJson(feature: feature))
          .toList();
    }

    return zone;
  }
}
