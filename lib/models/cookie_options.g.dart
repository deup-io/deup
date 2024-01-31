// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cookie_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CookieOptionsModel _$CookieOptionsModelFromJson(Map<String, dynamic> json) =>
    CookieOptionsModel()
      ..path = json['path'] as String?
      ..domain = json['domain'] as String?
      ..expiresDate = json['expiresDate'] as int?
      ..maxAge = json['maxAge'] as int?
      ..isSecure = json['isSecure'] as bool?
      ..isHttpOnly = json['isHttpOnly'] as bool?
      ..sameSite = json['sameSite'] as String?;

Map<String, dynamic> _$CookieOptionsModelToJson(CookieOptionsModel instance) =>
    <String, dynamic>{
      'path': instance.path,
      'domain': instance.domain,
      'expiresDate': instance.expiresDate,
      'maxAge': instance.maxAge,
      'isSecure': instance.isSecure,
      'isHttpOnly': instance.isHttpOnly,
      'sameSite': instance.sameSite,
    };
