// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patientImage.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatientImage _$PatientImageFromJson(Map<String, dynamic> json) {
  return PatientImage(
    id: json['ID'] as int,
    patientId: json['PATIENT_ID'] as int?,
    bodyPartId: json['BODY_PART_ID'] as int?,
    bodyPartTitle: json['BODY_PART_TITLE'] as String?,
    thumbUrl: json['THUMB_URL'] as String?,
    photoUrl: json['PHOTO_URL'] as String?,
    notes: json['NOTES'] as String?,
    createDate: json['CREATE_DATE'] as String?,
    lastUpdateDate: json['LAST_UPDATE_DATE'] as String?,
    medicalHistoryId: json['MEDICAL_HISTORY_ID'] as int?,
    medicalHistoryNo: json['MEDICAL_HISTORY_NO'] as String?,
  )
    ..isSelected = json['IS_SELECTED'] as bool?
    ..isUncategorized = json['IS_UNCATEGORIZED'] as int?;
}

Map<String, dynamic> _$PatientImageToJson(PatientImage instance) =>
    <String, dynamic>{
      'ID': instance.id,
      'IS_SELECTED': instance.isSelected,
      'PATIENT_ID': instance.patientId,
      'BODY_PART_ID': instance.bodyPartId,
      'BODY_PART_TITLE': instance.bodyPartTitle,
      'THUMB_URL': instance.thumbUrl,
      'PHOTO_URL': instance.photoUrl,
      'NOTES': instance.notes,
      'IS_UNCATEGORIZED': instance.isUncategorized,
      'CREATE_DATE': instance.createDate,
      'LAST_UPDATE_DATE': instance.lastUpdateDate,
      'MEDICAL_HISTORY_ID': instance.medicalHistoryId,
      'MEDICAL_HISTORY_NO': instance.medicalHistoryNo,
    };
