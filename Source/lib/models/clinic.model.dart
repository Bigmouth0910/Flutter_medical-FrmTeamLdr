import 'package:json_annotation/json_annotation.dart';

part 'clinic.model.g.dart';

@JsonSerializable()
class Clinic {
  Clinic(
      {required this.id,
      this.city,
      this.zip,
      this.title,
      this.url,
      this.state,
      this.email,
      this.phone,
      this.logo,
      this.address,
      this.createDate,
      this.lastUpdateDate});

  @JsonKey(name: 'ID')
  int id;
  @JsonKey(name: 'CITY')
  String? city;
  @JsonKey(name: 'ZIP')
  String? zip;
  @JsonKey(name: 'TITLE')
  String? title;
  @JsonKey(name: 'URL')
  String? url;
  @JsonKey(name: 'STATE')
  String? state;
  @JsonKey(name: 'EMAIL')
  String? email;
  @JsonKey(name: 'PHONE')
  String? phone;
  @JsonKey(name: 'LOGO')
  String? logo;
  @JsonKey(name: 'ADDRESS')
  String? address;
  @JsonKey(name: 'CREATE_DATE')
  String? createDate;
  @JsonKey(name: 'LAST_UPDATE_DATE')
  String? lastUpdateDate;

  factory Clinic.fromJson(Map<String, dynamic> json) => _$ClinicFromJson(json);
  Map<String, dynamic> toJson() => _$ClinicToJson(this);
}
