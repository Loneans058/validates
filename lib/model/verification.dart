import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'verification.g.dart';

@JsonSerializable(createToJson: false)
class EZError extends Equatable {
  @JsonKey(required: true, disallowNullValue: true)
  final int code;
  @JsonKey(required: true, disallowNullValue: true)
  final String message;

  const EZError({
    required this.code,
    required this.message,
  });

  factory EZError.fromJson(final Map<String, dynamic> json) =>
      _$EZErrorFromJson(json);

  @override
  List<Object?> get props => [code, message];
}

@JsonSerializable(createToJson: false)
class SmartshieldVerification extends Equatable {
  @JsonKey(required: true, disallowNullValue: true)
  final bool valid;
  @JsonKey()
  final EZError? err;

  const SmartshieldVerification({
    required this.valid,
    this.err,
  });
  factory SmartshieldVerification.fromJson(final Map<String, dynamic> json) =>
      _$SmartshieldVerificationFromJson(json);

  @override
  List<Object?> get props => [valid, err];
}

@JsonSerializable(createToJson: false)
class SmartshieldotpverifyService extends Equatable {
  @JsonKey(required: true, disallowNullValue: true)
  final bool valid;
  @JsonKey()
  final EZError? err;

  const SmartshieldotpverifyService({
    required this.valid,
    this.err,
  });
  factory SmartshieldotpverifyService.fromJson(final Map<String, dynamic> json) =>
      _$SmartshieldotpverifyServiceFromJson(json);

  @override
  List<Object?> get props => [valid, err];
}

@JsonSerializable(createToJson: false)
class SmartshieldotpsendService extends Equatable {
  @JsonKey(required: true, disallowNullValue: true)
  final bool valid;
  @JsonKey()
  final EZError? err;

  const SmartshieldotpsendService({
    required this.valid,
    this.err,
  });
  factory SmartshieldotpsendService.fromJson(final Map<String, dynamic> json) =>
      _$SmartshieldotpsendServiceFromJson(json);

  @override
  List<Object?> get props => [valid, err];
}
