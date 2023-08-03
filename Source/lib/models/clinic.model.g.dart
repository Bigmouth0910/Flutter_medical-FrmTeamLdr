// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clinic.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Clinic _$ClinicFromJson(Map<String, dynamic> json) {
  return Clinic(
    id: json['ID'] as int,
    city: json['CITY'] as String?,
    zip: json['ZIP'] as String?,
    title: json['TITLE'] as String?,
    url: json['URL'] as String?,
    state: json['STATE'] as String?,
    email: json['EMAIL'] as String?,
    phone: json['PHONE'] as String?,
    logo: json['LOGO'] as String?,
    address: json['ADDRESS'] as String?,
    createDate: json['CREATE_DATE'] as String?,
    lastUpdateDate: json['LAST_UPDATE_DATE'] as String?,
  );
}

Map<String, dynamic> _$ClinicToJson(Clinic instance) => <String, dynamic>{
      'ID': instance.id,
      'CITY': instance.city,
      'ZIP': instance.zip,
      'TITLE': instance.title,
      'URL': instance.url,
      'STATE': instance.state,
      'EMAIL': instance.email,
      'PHONE': instance.phone,
      'LOGO': instance.logo,
      'ADDRESS': instance.address,
      'CREATE_DATE': instance.createDate,
      'LAST_UPDATE_DATE': instance.lastUpdateDate,
    };
