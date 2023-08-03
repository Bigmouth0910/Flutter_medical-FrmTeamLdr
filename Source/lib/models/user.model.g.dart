// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  return User(
      id: json['ID'] as int?,
      userName: json['USERNAME'] as String?,
      password: json['PASSWORD'] as String?,
      firstName: json['FIRST_NAME'] as String?,
      lastName: json['LAST_NAME'] as String?,
      profileInfo: json['PROFILE_INFO'] as String?,
      clinic: json['CLINIC'] == null
          ? null
          : Clinic.fromJson(json['CLINIC'] as Map<String, dynamic>),
      role_type: json['ROLE_TYPE'] as int?);
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'ID': instance.id,
      'USERNAME': instance.userName,
      'PASSWORD': instance.password,
      'FIRST_NAME': instance.firstName,
      'LAST_NAME': instance.lastName,
      'PROFILE_INFO': instance.profileInfo,
      'CLINIC': instance.clinic,
      'ROLE_TYPE': instance.role_type,
    };
