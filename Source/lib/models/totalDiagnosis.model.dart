import 'package:json_annotation/json_annotation.dart';
import 'diagnosis.model.dart';

part 'totalDiagnosis.model.g.dart';

@JsonSerializable()
class TotalDiagnosis {
  TotalDiagnosis({
    required this.rows,
    required this.count,
  });

  @JsonKey(name: 'rows')
  List<Diagnosis> rows;
  @JsonKey(name: 'count')
  int count;

  factory TotalDiagnosis.fromJson(Map<String, dynamic> json) =>
      _$TotalDiagnosisFromJson(json);
  Map<String, dynamic> toJson() => _$TotalDiagnosisToJson(this);
}
