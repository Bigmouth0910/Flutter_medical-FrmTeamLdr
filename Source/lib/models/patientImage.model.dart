import 'package:json_annotation/json_annotation.dart';

part 'patientImage.model.g.dart';

@JsonSerializable()
class PatientImage {
  PatientImage({
    required this.id,
    this.patientId,
    this.bodyPartId,
    this.bodyPartTitle,
    this.thumbUrl,
    this.photoUrl,
    this.notes,
    this.createDate,
    this.lastUpdateDate,
    this.medicalHistoryId,
    this.medicalHistoryNo,
    this.isSelected,
  });

  @JsonKey(name: 'ID')
  int id;
  @JsonKey(name: 'IS_SELECTED')
  bool? isSelected = false;
  @JsonKey(name: 'PATIENT_ID')
  int? patientId;
  @JsonKey(name: 'BODY_PART_ID')
  int? bodyPartId;
  @JsonKey(name: 'BODY_PART_TITLE')
  String? bodyPartTitle;
  @JsonKey(name: 'THUMB_URL')
  String? thumbUrl;
  @JsonKey(name: 'PHOTO_URL')
  String? photoUrl;
  @JsonKey(name: 'NOTES')
  String? notes;
  @JsonKey(name: 'IS_UNCATEGORIZED')
  int? isUncategorized;
  @JsonKey(name: 'CREATE_DATE')
  String? createDate;
  @JsonKey(name: 'LAST_UPDATE_DATE')
  String? lastUpdateDate;
  @JsonKey(name: 'MEDICAL_HISTORY_ID')
  int? medicalHistoryId = 0;
  @JsonKey(name: 'MEDICAL_HISTORY_NO')
  String? medicalHistoryNo = '';
  factory PatientImage.fromJson(Map<String, dynamic> json) =>
      _$PatientImageFromJson(json);
  Map<String, dynamic> toJson() => _$PatientImageToJson(this);
}
