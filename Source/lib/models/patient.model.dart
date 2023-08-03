import 'package:json_annotation/json_annotation.dart';

part 'patient.model.g.dart';

@JsonSerializable()
class Patient {
  Patient({
    required this.id,
    required this.doctorId,
    this.firstName,
    this.lastName,
    this.filePath,
    this.birthDate,
    this.city,
    this.isActive,
    this.notes,
    this.signedImage,
    this.createDate,
    this.lastUpdateDate,
  });
  @JsonKey(name: 'ID')
  int id;
  @JsonKey(name: 'DOCTOR_ID')
  int doctorId;
  @JsonKey(name: 'FIRST_NAME')
  String? firstName;
  @JsonKey(name: 'LAST_NAME')
  String? lastName;
  @JsonKey(name: 'FILE_PATH')
  String? filePath;
  @JsonKey(name: 'BIRTH_DATE')
  String? birthDate;
  @JsonKey(name: 'CITY')
  String? city;
  @JsonKey(name: 'DIAGNOSIS')
  dynamic diagnosis;
  @JsonKey(name: 'TREATMENT')
  dynamic treatment;
  @JsonKey(name: 'NOTES')
  String? notes;
  @JsonKey(name: 'IS_ACTIVE')
  int? isActive;
  @JsonKey(name: 'MEDICAL_HISTORY_NO')
  String? medicalHistoryNo;
  @JsonKey(name: 'SIGNED_IMAGE')
  String? signedImage;
  @JsonKey(name: 'CREATE_DATE')
  String? createDate;
  @JsonKey(name: 'LAST_UPDATE_DATE')
  String? lastUpdateDate;

  factory Patient.fromJson(Map<String, dynamic> json) =>
      _$PatientFromJson(json);

  Map<String, dynamic> toJson() => _$PatientToJson(this);
}
