import 'package:json_annotation/json_annotation.dart';

part 'diagnosis.model.g.dart';

@JsonSerializable()
class Diagnosis {
  Diagnosis(
      {required this.id,
      this.parentId,
      this.tagName,
      this.createDate,
      this.lastUpdateDate,
      this.children});

  @JsonKey(name: 'ID')
  int id;
  @JsonKey(name: 'PARENT_ID')
  int? parentId;
  @JsonKey(name: 'TAG_NAME')
  String? tagName;
  @JsonKey(name: 'CREATE_DATE')
  String? createDate;
  @JsonKey(name: 'LAST_UPDATE_DATE')
  String? lastUpdateDate;
  @JsonKey(name: 'children')
  List<Diagnosis>? children;

  factory Diagnosis.fromJson(Map<String, dynamic> json) =>
      _$DiagnosisFromJson(json);
  Map<String, dynamic> toJson() => _$DiagnosisToJson(this);
}
