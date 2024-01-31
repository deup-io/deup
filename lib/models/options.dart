import 'package:json_annotation/json_annotation.dart';

part 'options.g.dart';

@JsonSerializable()
class OptionsModel {
  OptionsModel();

  @JsonKey(name: 'icon') bool? icon;
  @JsonKey(name: 'hideNavBar') bool? hideNavBar;
  @JsonKey(name: 'layout') String? layout;
  @JsonKey(name: 'pageSize') int? pageSize;
  
  factory OptionsModel.fromJson(Map<String,dynamic> json) => _$OptionsModelFromJson(json);
  Map<String, dynamic> toJson() => _$OptionsModelToJson(this);
}
