import 'package:json_annotation/json_annotation.dart';

part 'cookie_options.g.dart';

@JsonSerializable()
class CookieOptionsModel {
  CookieOptionsModel();

  @JsonKey(name: 'path') String? path;
  @JsonKey(name: 'domain') String? domain;
  @JsonKey(name: 'expiresDate') int? expiresDate;
  @JsonKey(name: 'maxAge') int? maxAge;
  @JsonKey(name: 'isSecure') bool? isSecure;
  @JsonKey(name: 'isHttpOnly') bool? isHttpOnly;
  @JsonKey(name: 'sameSite') String? sameSite;
  
  factory CookieOptionsModel.fromJson(Map<String,dynamic> json) => _$CookieOptionsModelFromJson(json);
  Map<String, dynamic> toJson() => _$CookieOptionsModelToJson(this);
}
