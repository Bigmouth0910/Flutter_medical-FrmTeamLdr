// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Patient _$PatientFromJson(Map<String, dynamic> json) {
  return Patient(
    id: json['ID'] as int,
    doctorId: json['DOCTOR_ID'] as int,
    firstName: json['FIRST_NAME'] as String?,
    lastName: json['LAST_NAME'] as String?,
    filePath: json['FILE_PATH'] as String?,
    birthDate: json['BIRTH_DATE'] as String?,
    city: json['CITY'] as String?,
    isActive: json['IS_ACTIVE'] as int?,
    notes: json['NOTES'] as String?,
    signedImage: json['SIGNED_IMAGE'] as String?,
    createDate: json['CREATE_DATE'] as String?,
    lastUpdateDate: json['LAST_UPDATE_DATE'] as String?,
  )
    ..diagnosis = json['DIAGNOSIS']
    ..treatment = json['TREATMENT']
    ..medicalHistoryNo = json['MEDICAL_HISTORY_NO'] as String?;
}

Map<String, dynamic> _$PatientToJson(Patient instance) => <String, dynamic>{
      'ID': instance.id,
      'DOCTOR_ID': instance.doctorId,
      'FIRST_NAME': instance.firstName,
      'LAST_NAME': instance.lastName,
      'FILE_PATH': instance.filePath,
      'BIRTH_DATE': instance.birthDate,
      'CITY': instance.city,
      'DIAGNOSIS': instance.diagnosis,
      'TREATMENT': instance.treatment,
      'NOTES': instance.notes,
      'IS_ACTIVE': instance.isActive,
      'MEDICAL_HISTORY_NO': instance.medicalHistoryNo,
      'SIGNED_IMAGE': instance.signedImage,
      'CREATE_DATE': instance.createDate,
      'LAST_UPDATE_DATE': instance.lastUpdateDate,
    };
