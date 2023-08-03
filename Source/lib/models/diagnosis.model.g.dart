// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagnosis.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Diagnosis _$DiagnosisFromJson(Map<String, dynamic> json) {
  return Diagnosis(
    id: json['ID'] as int,
    parentId: json['PARENT_ID'] as int?,
    tagName: json['TAG_NAME'] as String?,
    createDate: json['CREATE_DATE'] as String?,
    lastUpdateDate: json['LAST_UPDATE_DATE'] as String?,
    children: (json['children'] as List<dynamic>?)
        ?.map((e) => Diagnosis.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$DiagnosisToJson(Diagnosis instance) => <String, dynamic>{
      'ID': instance.id,
      'PARENT_ID': instance.parentId,
      'TAG_NAME': instance.tagName,
      'CREATE_DATE': instance.createDate,
      'LAST_UPDATE_DATE': instance.lastUpdateDate,
      'children': instance.children,
    };
