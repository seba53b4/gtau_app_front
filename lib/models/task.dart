
class Task {
  late int? id;
  late String? inspectionType;
  late String? workNumber;
  late DateTime? addDate;
  late String? applicant;
  late String? location;
  late String? description;
  late DateTime? releasedDate;
  late String? user;
  late String? length;
  late String? material;
  late String? observations;
  late String? conclusions;

  int? get getId => id;
  set setId(int? value) => id = value;

  String? get getInspectionType => inspectionType;
  set setInspectionType(String? value) => inspectionType = value;

  String? get getWorkNumber => workNumber;
  set setWorkNumber(String? value) => workNumber = value;

  DateTime? get getAddDate => addDate;
  set setAddDate(DateTime? value) => addDate = value;

  String? get getApplicant => applicant;
  set setApplicant(String? value) => applicant = value;

  String? get getLocation => location;
  set setLocation(String? value) => location = value;

  String? get getDescription => description;
  set setDescription(String? value) => description = value;

  DateTime? get getReleasedDate => releasedDate;
  set setReleasedDate(DateTime? value) => releasedDate = value;

  String? get getUser => user;
  set setUser(String? value) => user = value;

  String? get getLength => length;
  set setLength(String? value) => length = value;

  String? get getMaterial => material;
  set setMaterial(String? value) => material = value;

  String? get getObservations => observations;
  set setObservations(String? value) => observations = value;

  String? get getConclusions => conclusions;
  set setConclusions(String? value) => conclusions = value;

  Task({
    required this.id,
    required this.inspectionType,
    required this.workNumber,
    required this.addDate,
    required this.applicant,
    required this.location,
    required this.description,
    this.releasedDate,
    required this.user,
    required this.length,
    required this.material,
    required this.observations,
    required this.conclusions,
  });
}