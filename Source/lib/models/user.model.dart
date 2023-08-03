import 'package:json_annotation/json_annotation.dart';
import 'clinic.model.dart';

part 'user.model.g.dart';

@JsonSerializable()
class User {
  User({
    this.id,
    this.userName,
    this.password,
    this.firstName,
    this.lastName,
    this.profileInfo,
    this.clinic,
    this.role_type,
  }) {
    this.id = id;
    this.userName = userName;
    this.password = password;
    this.firstName = firstName;
    this.lastName = lastName;
    this.profileInfo = profileInfo;
    this.clinic = clinic;
    this.role_type = role_type;
  }
  @JsonKey(name: 'ID')
  int? id;
  @JsonKey(name: 'USERNAME')
  String? userName;
  @JsonKey(name: 'PASSWORD')
  String? password;
  @JsonKey(name: 'FIRST_NAME')
  String? firstName;
  @JsonKey(name: 'LAST_NAME')
  String? lastName;
  @JsonKey(name: 'PROFILE_INFO')
  String? profileInfo;
  @JsonKey(name: 'CLINIC')
  Clinic? clinic;
  @JsonKey(name: 'ROLE_TYPE')
  int? role_type;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
