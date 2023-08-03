// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicalhistory.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MedicalHistory _$MedicalHistoryFromJson(Map<String, dynamic> json) {
  return MedicalHistory(
    id: json['ID'] as int,
    medicalHistoryNo: json['MEDICAL_HISTORY_NO'] as String,
    attendingPhysician: json['ATTENDING_PHYSICIAN'] as String?,
    diagnosis: json['DIAGNOSIS'],
    treatment: json['TREATMENT'],
    notes: json['NOTES'] as String?,
    dateOfVisit: json['DATEOFVISIT'] as String?,
    createDate: json['CREATE_DATE'] as String?,
    lastUpdateDate: json['LAST_UPDATE_DATE'] as String?,
  );
}

Map<String, dynamic> _$MedicalHistoryToJson(MedicalHistory instance) =>
    <String, dynamic>{
      'ID': instance.id,
      'MEDICAL_HISTORY_NO': instance.medicalHistoryNo,
      'ATTENDING_PHYSICIAN': instance.attendingPhysician,
      'DIAGNOSIS': instance.diagnosis,
      'TREATMENT': instance.treatment,
      'NOTES': instance.notes,
      'DATEOFVISIT': instance.dateOfVisit,
      'CREATE_DATE': instance.createDate,
      'LAST_UPDATE_DATE': instance.lastUpdateDate,
    };
