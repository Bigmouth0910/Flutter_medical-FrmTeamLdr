import 'package:json_annotation/json_annotation.dart';

part 'treatmentInfo.model.g.dart';

@JsonSerializable()
class TreatmentInfo {
  TreatmentInfo({
    required this.id,
    this.parentId,
    required this.tagName,
    required this.injectionColor,
    required this.createDate,
    required this.lastUpdateDate,
  });
  @JsonKey(name: 'ID')
  int id;
  @JsonKey(name: 'PARENT_ID')
  int? parentId;
  @JsonKey(name: 'TAG_NAME')
  String tagName;
  @JsonKey(name: 'INJECTION_COLOR')
  String? injectionColor;
  @JsonKey(name: 'CREATE_DATE')
  String createDate;
  @JsonKey(name: 'LAST_UPDATE_DATE')
  String lastUpdateDate;
  @JsonKey(name: 'children')
  List<TreatmentInfo>? children;

  factory TreatmentInfo.fromJson(Map<String, dynamic> json) =>
      _$TreatmentInfoFromJson(json);

  Map<String, dynamic> toJson() => _$TreatmentInfoToJson(this);
}
