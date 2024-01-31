// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PluginConfigModel _$PluginConfigModelFromJson(Map<String, dynamic> json) =>
    PluginConfigModel()
      ..name = json['name'] as String?
      ..description = json['description'] as String?
      ..headers = (json['headers'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      )
      ..logo = json['logo'] as String?
      ..color = json['color'] as String?
      ..background = json['background']
      ..timeout = json['timeout'] as int?
      ..layout = json['layout'] as String?
      ..hasInput = json['hasInput'] as bool?
      ..historyLayout = json['historyLayout'] as String?
      ..pageSize = json['pageSize'] as int?;

Map<String, dynamic> _$PluginConfigModelToJson(PluginConfigModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'headers': instance.headers,
      'logo': instance.logo,
      'color': instance.color,
      'background': instance.background,
      'timeout': instance.timeout,
      'layout': instance.layout,
      'hasInput': instance.hasInput,
      'historyLayout': instance.historyLayout,
      'pageSize': instance.pageSize,
    };
