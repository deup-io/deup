import 'package:json_annotation/json_annotation.dart';

part 'input.g.dart';

@JsonSerializable()
class PluginInputModel {
  PluginInputModel();

  @JsonKey(name: 'label') String? label;
  @JsonKey(name: 'required') bool? required;
  @JsonKey(name: 'placeholder') String? placeholder;
  
  factory PluginInputModel.fromJson(Map<String,dynamic> json) => _$PluginInputModelFromJson(json);
  Map<String, dynamic> toJson() => _$PluginInputModelToJson(this);
}
