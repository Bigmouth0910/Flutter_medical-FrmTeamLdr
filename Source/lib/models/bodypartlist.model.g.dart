// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bodypartlist.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BodyPartList _$BodyPartListFromJson(Map<String, dynamic> json) {
  return BodyPartList(
    id: json['ID'] as int,
    name: json['NAME'] as String?,
    createDate: json['CREATE_DATE'] as String?,
    lastUpdateDate: json['LAST_UPDATE_DATE'] as String?,
  );
}

Map<String, dynamic> _$BodyPartListToJson(BodyPartList instance) =>
    <String, dynamic>{
      'ID': instance.id,
      'NAME': instance.name,
      'CREATE_DATE': instance.createDate,
      'LAST_UPDATE_DATE': instance.lastUpdateDate,
    };
