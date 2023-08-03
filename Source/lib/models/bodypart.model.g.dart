// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bodypart.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BodyPart _$BodyPartFromJson(Map<String, dynamic> json) {
  return BodyPart(
    id: json['ID'] as int,
    title: json['TITLE'] as String?,
    partsFor: json['PARTSFOR'] as int?,
    photoImagePath: json['PHOTO_IMAGE_PATH'] as String?,
    templateImagePath: json['TEMPLATE_IMAGE_PATH'] as String?,
    createDate: json['CREATE_DATE'] as String?,
    lastUpdateDate: json['LAST_UPDATE_DATE'] as String?,
  );
}

Map<String, dynamic> _$BodyPartToJson(BodyPart instance) => <String, dynamic>{
      'ID': instance.id,
      'TITLE': instance.title,
      'PARTSFOR': instance.partsFor,
      'PHOTO_IMAGE_PATH': instance.photoImagePath,
      'TEMPLATE_IMAGE_PATH': instance.templateImagePath,
      'CREATE_DATE': instance.createDate,
      'LAST_UPDATE_DATE': instance.lastUpdateDate,
    };
