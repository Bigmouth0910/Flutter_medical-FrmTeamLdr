import 'package:json_annotation/json_annotation.dart';

part 'medicalhistory.model.g.dart';

@JsonSerializable()
class MedicalHistory {
  MedicalHistory({
    required this.id,
    required this.medicalHistoryNo,
    this.attendingPhysician,
    this.diagnosis,
    this.treatment,
    this.notes,
    this.dateOfVisit,
    this.createDate,
    this.lastUpdateDate,
  });
  @JsonKey(name: 'ID')
  int id;
  @JsonKey(name: 'MEDICAL_HISTORY_NO')
  String medicalHistoryNo;
  @JsonKey(name: 'ATTENDING_PHYSICIAN')
  String? attendingPhysician;
  @JsonKey(name: 'DIAGNOSIS')
  dynamic diagnosis;
  @JsonKey(name: 'TREATMENT')
  dynamic treatment;
  @JsonKey(name: 'NOTES')
  String? notes;
  @JsonKey(name: 'DATEOFVISIT')
  String? dateOfVisit;
  @JsonKey(name: 'CREATE_DATE')
  String? createDate;
  @JsonKey(name: 'LAST_UPDATE_DATE')
  String? lastUpdateDate;

  factory MedicalHistory.fromJson(Map<String, dynamic> json) =>
      _$MedicalHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$MedicalHistoryToJson(this);
}
