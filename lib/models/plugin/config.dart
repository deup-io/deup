import 'package:json_annotation/json_annotation.dart';

part 'config.g.dart';

@JsonSerializable()
class PluginConfigModel {
  PluginConfigModel();

  @JsonKey(name: 'name') String? name;
  @JsonKey(name: 'description') String? description;
  @JsonKey(name: 'headers') Map<String, String>? headers;
  @JsonKey(name: 'logo') String? logo;
  @JsonKey(name: 'color') String? color;
  @JsonKey(name: 'background') dynamic background;
  @JsonKey(name: 'timeout') int? timeout;
  @JsonKey(name: 'layout') String? layout;
  @JsonKey(name: 'hasInput') bool? hasInput;
  @JsonKey(name: 'historyLayout') String? historyLayout;
  @JsonKey(name: 'pageSize') int? pageSize;
  
  factory PluginConfigModel.fromJson(Map<String,dynamic> json) => _$PluginConfigModelFromJson(json);
  Map<String, dynamic> toJson() => _$PluginConfigModelToJson(this);
}
