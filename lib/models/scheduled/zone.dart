import 'package:gtau_app_front/models/scheduled/subzone.dart';

class ScheduledZone {
  late int? id;
  late String? name;
  late List<ScheduledSubZone>? subZones;

  ScheduledZone({
    this.id,
    this.name,
    this.subZones,
  });

  factory ScheduledZone.fromJson({required Map<String, dynamic> json}) {
    final zone = ScheduledZone(
      id: json['id'] as int?,
      name: json['name'] as String?,
    );

    if (json.containsKey('features')) {
      final List<dynamic> features = json['features'];
      zone.subZones = features
          .map((feature) => ScheduledSubZone.fromJson(feature: feature))
          .toList();
    }

    return zone;
  }
}
