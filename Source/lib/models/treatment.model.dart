import 'package:json_annotation/json_annotation.dart';

part 'treatment.model.g.dart';

@JsonSerializable()
class Treatment {
  Treatment({
    required this.id,
    this.parentId,
    required this.tagName,
    required this.createDate,
    required this.lastUpdateDate,
    required this.children,
  });
  @JsonKey(name: 'ID')
  int id;
  @JsonKey(name: 'PARENT_ID')
  int? parentId;
  @JsonKey(name: 'TAG_NAME')
  String tagName;
  @JsonKey(name: 'CREATE_DATE')
  String createDate;
  @JsonKey(name: 'LAST_UPDATE_DATE')
  String lastUpdateDate;
  @JsonKey(name: 'children')
  List<Treatment>? children;

  factory Treatment.fromJson(Map<String, dynamic> json) =>
      _$TreatmentFromJson(json);

  Map<String, dynamic> toJson() => _$TreatmentToJson(this);
}
