// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permissions.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PermissionsModel _$PermissionsModelFromJson(Map<String, dynamic> json) =>
    PermissionsModel()
      ..write = json['write'] as bool?
      ..rename = json['rename'] as bool?
      ..move = json['move'] as bool?
      ..copy = json['copy'] as bool?
      ..delete = json['delete'] as bool?;

Map<String, dynamic> _$PermissionsModelToJson(PermissionsModel instance) =>
    <String, dynamic>{
      'write': instance.write,
      'rename': instance.rename,
      'move': instance.move,
      'copy': instance.copy,
      'delete': instance.delete,
    };
