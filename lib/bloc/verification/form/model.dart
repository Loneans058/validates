part of 'cubit.dart';

enum VerificationFormNameValidationError { empty }

final class VerificationFormName
    extends FormzInput<String, VerificationFormNameValidationError> {
  final VerificationFormNameValidationError? externalError;

  const VerificationFormName.pure()
      : externalError = null,
        super.pure('');
  const VerificationFormName.dirty({
    this.externalError,
    required final String value,
  }) : super.dirty(value);

  @override
  VerificationFormNameValidationError? validator(final String value) {
    if (value.isEmpty) {
      return VerificationFormNameValidationError.empty;
    }
    return externalError;
  }
}

enum VerificationFormRecordIdValidationError { empty, notFound }

final class VerificationFormRecordId
    extends FormzInput<String, VerificationFormRecordIdValidationError> {
  final VerificationFormRecordIdValidationError? externalError;

  const VerificationFormRecordId.pure()
      : externalError = null,
        super.pure('');
  const VerificationFormRecordId.dirty({
    this.externalError,
    required final String value,
  }) : super.dirty(value);

  @override
  VerificationFormRecordIdValidationError? validator(final String value) {
    if (value.isEmpty) {
      return VerificationFormRecordIdValidationError.empty;
    }
    return externalError;
  }
}

enum VerificationFormEmailValidationError { empty, invalid }

final class VerificationFormEmail
    extends FormzInput<String, VerificationFormEmailValidationError> {
  const VerificationFormEmail.pure() : super.pure('');
  const VerificationFormEmail.dirty(super.value) : super.dirty();

  @override
  VerificationFormEmailValidationError? validator(final String value) {
    if (value.isEmpty) {
      return VerificationFormEmailValidationError.empty;
    }
    const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
        r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
        r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
        r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
        r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
        r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
        r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
    final regex = RegExp(pattern);

    return value.isNotEmpty && !regex.hasMatch(value)
        ? VerificationFormEmailValidationError.invalid
        : null;
  }
}

enum VerificationFormFileValidationError { empty }

final class VerificationFormFile
    extends FormzInput<Uint8List?, VerificationFormFileValidationError> {
  const VerificationFormFile.pure() : super.pure(null);
  const VerificationFormFile.dirty(super.value) : super.dirty();

  @override
  VerificationFormFileValidationError? validator(final Uint8List? value) {
    if (value == null) {
      return VerificationFormFileValidationError.empty;
    }
    return null;
  }
}
