// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OptionsModel _$OptionsModelFromJson(Map<String, dynamic> json) => OptionsModel()
  ..icon = json['icon'] as bool?
  ..hideNavBar = json['hideNavBar'] as bool?
  ..layout = json['layout'] as String?
  ..pageSize = json['pageSize'] as int?;

Map<String, dynamic> _$OptionsModelToJson(OptionsModel instance) =>
    <String, dynamic>{
      'icon': instance.icon,
      'hideNavBar': instance.hideNavBar,
      'layout': instance.layout,
      'pageSize': instance.pageSize,
    };
