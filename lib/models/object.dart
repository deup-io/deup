import 'package:json_annotation/json_annotation.dart';
import 'options.dart';
part 'object.g.dart';

@JsonSerializable()
class ObjectModel {
  ObjectModel();

  @JsonKey(name: 'id') String? id;
  @JsonKey(name: 'name') String? name;
  @JsonKey(name: 'description') String? description;
  @JsonKey(name: 'type') String? type;
  @JsonKey(name: 'created') DateTime? created;
  @JsonKey(name: 'modified') DateTime? modified;
  @JsonKey(name: 'size') int? size;
  @JsonKey(name: 'url') String? url;
  @JsonKey(name: 'cover') String? cover;
  @JsonKey(name: 'poster') String? poster;
  @JsonKey(name: 'thumbnail') String? thumbnail;
  @JsonKey(name: 'remark') String? remark;
  @JsonKey(name: 'isLive') bool? isLive;
  @JsonKey(name: 'extra') Map<String, dynamic>? extra;
  @JsonKey(name: 'related') List<ObjectModel>? related;
  @JsonKey(name: 'options') OptionsModel? options;
  @JsonKey(name: 'headers') Map<String, String>? headers;
  
  factory ObjectModel.fromJson(Map<String,dynamic> json) => _$ObjectModelFromJson(json);
  Map<String, dynamic> toJson() => _$ObjectModelToJson(this);
}
