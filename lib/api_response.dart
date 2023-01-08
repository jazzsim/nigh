import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  T response;
  String message;
  ApiResponse(this.response, this.message);

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Object? json) fromJsonT) => _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) => _$ApiResponseToJson(this, toJsonT);
}
