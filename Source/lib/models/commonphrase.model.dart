import 'package:json_annotation/json_annotation.dart';

part 'commonphrase.model.g.dart';

@JsonSerializable()
class CommonPhrase {
  CommonPhrase(
      {required this.id,
      this.parentId,
      this.tagName,
      this.createDate,
      this.lastUpdateDate});

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
  List<CommonPhrase>? children;
  factory CommonPhrase.fromJson(Map<String, dynamic> json) =>
      _$CommonPhraseFromJson(json);
  Map<String, dynamic> toJson() => _$CommonPhraseToJson(this);
}
