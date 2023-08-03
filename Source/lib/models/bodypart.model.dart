import 'package:json_annotation/json_annotation.dart';

part 'bodypart.model.g.dart';

@JsonSerializable()
class BodyPart {
  BodyPart(
      {required this.id,
      this.title,
      this.partsFor,
      this.photoImagePath,
      this.templateImagePath,
      this.createDate,
      this.lastUpdateDate});
  @JsonKey(name: 'ID')
  int id;
  @JsonKey(name: 'TITLE')
  String? title;
  @JsonKey(name: 'PARTSFOR')
  int? partsFor;
  @JsonKey(name: 'PHOTO_IMAGE_PATH')
  String? photoImagePath;
  @JsonKey(name: 'TEMPLATE_IMAGE_PATH')
  String? templateImagePath;
  @JsonKey(name: 'CREATE_DATE')
  String? createDate;
  @JsonKey(name: 'LAST_UPDATE_DATE')
  String? lastUpdateDate;

  factory BodyPart.fromJson(Map<String, dynamic> json) =>
      _$BodyPartFromJson(json);

  Map<String, dynamic> toJson() => _$BodyPartToJson(this);
}
