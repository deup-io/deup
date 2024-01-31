// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'input.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PluginInputModel _$PluginInputModelFromJson(Map<String, dynamic> json) =>
    PluginInputModel()
      ..label = json['label'] as String?
      ..required = json['required'] as bool?
      ..placeholder = json['placeholder'] as String?;

Map<String, dynamic> _$PluginInputModelToJson(PluginInputModel instance) =>
    <String, dynamic>{
      'label': instance.label,
      'required': instance.required,
      'placeholder': instance.placeholder,
    };
