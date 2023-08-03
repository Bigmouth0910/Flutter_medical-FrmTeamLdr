// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'totalTreatment.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TotalTreatment _$TotalTreatmentFromJson(Map<String, dynamic> json) {
  return TotalTreatment(
    count: json['count'] as int?,
    rows: (json['rows'] as List<dynamic>?)
        ?.map((e) => Treatment.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$TotalTreatmentToJson(TotalTreatment instance) =>
    <String, dynamic>{
      'count': instance.count,
      'rows': instance.rows,
    };
