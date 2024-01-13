import 'dart:core';

class TaskScheduled {
  late int? id;
  late String? status;
  late DateTime? addDate;
  late String? description;
  late DateTime? releasedDate;

  TaskScheduled({
    this.id,
    this.status,
    this.addDate,
    this.description,
    this.releasedDate,
  });

  factory TaskScheduled.fromJson({required Map<String, dynamic> json}) {
    return TaskScheduled(
      id: json['id'] as int,
      status: json['status'] as String,
      addDate: DateTime.parse(json['addDate'] as String),
      description: json['description'] as String,
      releasedDate: json['releasedDate'] != null
          ? DateTime.parse(json['releasedDate'])
          : null,
    );
  }
}
