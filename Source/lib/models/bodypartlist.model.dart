import 'package:json_annotation/json_annotation.dart';

part 'bodypartlist.model.g.dart';

@JsonSerializable()
class BodyPartList {
  BodyPartList(
      {required this.id, this.name, this.createDate, this.lastUpdateDate});
  @JsonKey(name: 'ID')
  int id;
  @JsonKey(name: 'NAME')
  String? name;
  @JsonKey(name: 'CREATE_DATE')
  String? createDate;
  @JsonKey(name: 'LAST_UPDATE_DATE')
  String? lastUpdateDate;

  factory BodyPartList.fromJson(Map<String, dynamic> json) =>
      _$BodyPartListFromJson(json);

  Map<String, dynamic> toJson() => _$BodyPartListToJson(this);
}
