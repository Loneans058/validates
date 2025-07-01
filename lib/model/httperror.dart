import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'httperror.g.dart';

@JsonSerializable()
class AuthHttpError implements Exception {
  @JsonKey(required: true, disallowNullValue: true)
  final String error;

  @JsonKey(name: "error_description", required: true, disallowNullValue: true)
  final String description;

  AuthHttpError({required this.error, required this.description});
  factory AuthHttpError.fromJson(final Map<String, dynamic> json) =>
      _$AuthHttpErrorFromJson(json);

  @override
  String toString() =>
      const JsonEncoder.withIndent('  ').convert(_$AuthHttpErrorToJson(this));
}

@JsonSerializable()
class HttpError implements Exception {
  final int? code;
  final String message;
  const HttpError(this.code, this.message);
  factory HttpError.fromJson(final Map<String, dynamic> json) =>
      _$HttpErrorFromJson(json);

  @override
  String toString() =>
      const JsonEncoder.withIndent('  ').convert(_$HttpErrorToJson(this));
}
