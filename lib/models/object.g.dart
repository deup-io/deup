// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ObjectModel _$ObjectModelFromJson(Map<String, dynamic> json) => ObjectModel()
  ..id = json['id'] as String?
  ..name = json['name'] as String?
  ..description = json['description'] as String?
  ..type = json['type'] as String?
  ..created =
      json['created'] == null ? null : DateTime.parse(json['created'] as String)
  ..modified = json['modified'] == null
      ? null
      : DateTime.parse(json['modified'] as String)
  ..size = json['size'] as int?
  ..url = json['url'] as String?
  ..cover = json['cover'] as String?
  ..poster = json['poster'] as String?
  ..thumbnail = json['thumbnail'] as String?
  ..remark = json['remark'] as String?
  ..isLive = json['isLive'] as bool?
  ..extra = json['extra'] as Map<String, dynamic>?
  ..related = (json['related'] as List<dynamic>?)
      ?.map((e) => ObjectModel.fromJson(e as Map<String, dynamic>))
      .toList()
  ..options = json['options'] == null
      ? null
      : OptionsModel.fromJson(json['options'] as Map<String, dynamic>)
  ..headers = (json['headers'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  );

Map<String, dynamic> _$ObjectModelToJson(ObjectModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': instance.type,
      'created': instance.created?.toIso8601String(),
      'modified': instance.modified?.toIso8601String(),
      'size': instance.size,
      'url': instance.url,
      'cover': instance.cover,
      'poster': instance.poster,
      'thumbnail': instance.thumbnail,
      'remark': instance.remark,
      'isLive': instance.isLive,
      'extra': instance.extra,
      'related': instance.related,
      'options': instance.options,
      'headers': instance.headers,
    };
