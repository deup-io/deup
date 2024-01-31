import 'package:json_annotation/json_annotation.dart';

part 'permissions.g.dart';

@JsonSerializable()
class PermissionsModel {
  PermissionsModel();

  @JsonKey(name: 'write') bool? write;
  @JsonKey(name: 'rename') bool? rename;
  @JsonKey(name: 'move') bool? move;
  @JsonKey(name: 'copy') bool? copy;
  @JsonKey(name: 'delete') bool? delete;
  
  factory PermissionsModel.fromJson(Map<String,dynamic> json) => _$PermissionsModelFromJson(json);
  Map<String, dynamic> toJson() => _$PermissionsModelToJson(this);
}
