// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'treatmentInfo.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TreatmentInfo _$TreatmentInfoFromJson(Map<String, dynamic> json) {
  return TreatmentInfo(
    id: json['ID'] as int,
    parentId: json['PARENT_ID'] as int?,
    tagName: json['TAG_NAME'] as String,
    injectionColor: json['INJECTION_COLOR'] as String?,
    createDate: json['CREATE_DATE'] as String,
    lastUpdateDate: json['LAST_UPDATE_DATE'] as String,
  )..children = (json['children'] as List<dynamic>?)
      ?.map((e) => TreatmentInfo.fromJson(e as Map<String, dynamic>))
      .toList();
}

Map<String, dynamic> _$TreatmentInfoToJson(TreatmentInfo instance) =>
    <String, dynamic>{
      'ID': instance.id,
      'PARENT_ID': instance.parentId,
      'TAG_NAME': instance.tagName,
      'INJECTION_COLOR': instance.injectionColor,
      'CREATE_DATE': instance.createDate,
      'LAST_UPDATE_DATE': instance.lastUpdateDate,
      'children': instance.children,
    };
