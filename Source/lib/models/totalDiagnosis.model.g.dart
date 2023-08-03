// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'totalDiagnosis.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TotalDiagnosis _$TotalDiagnosisFromJson(Map<String, dynamic> json) {
  return TotalDiagnosis(
    rows: (json['rows'] as List<dynamic>)
        .map((e) => Diagnosis.fromJson(e as Map<String, dynamic>))
        .toList(),
    count: json['count'] as int,
  );
}

Map<String, dynamic> _$TotalDiagnosisToJson(TotalDiagnosis instance) =>
    <String, dynamic>{
      'rows': instance.rows,
      'count': instance.count,
    };
