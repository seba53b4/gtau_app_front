class Report {
  late int? id;
  late String? url;
  late DateTime? date;

  Report({
    this.id,
    this.url,
    this.date,
  });

  factory Report.fromJson({required Map<String, dynamic> json}) {
    return Report(
      id: json['id'] as int?,
      url: json['file'] as String?,
      date:
          json['date'] != null ? DateTime.parse(json['date'] as String) : null,
    );
  }
}
