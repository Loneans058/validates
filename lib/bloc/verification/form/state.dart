part of 'cubit.dart';

final class VerificationFormState extends Equatable {
  final VerificationFormName name;
  final VerificationFormEmail email;
  final VerificationFormRecordId recordId;
  final VerificationFormFile file;
  final VerificationFormSubmitState submitState;

  final int? maxTry, pageSize;
  final bool isValid;

  const VerificationFormState({
    this.name = const VerificationFormName.pure(),
    this.email = const VerificationFormEmail.pure(),
    this.recordId = const VerificationFormRecordId.pure(),
    this.file = const VerificationFormFile.pure(),
    this.maxTry,
    this.pageSize,
    this.isValid = false,
    this.submitState = const VerificationFormSubmitStateInitial(),
  });

  VerificationFormState copyWith({
    final VerificationFormName? name,
    final VerificationFormEmail? email,
    final VerificationFormRecordId? recordId,
    final VerificationFormFile? file,
    final int? maxTry,
    final int? pageSize,
    final bool? isValid,
    final VerificationFormSubmitState? submitState,
  }) =>
      VerificationFormState(
        name: name ?? this.name,
        email: email ?? this.email,
        recordId: recordId ?? this.recordId,
        file: file ?? this.file,
        maxTry: maxTry,
        pageSize: pageSize,
        isValid: isValid ?? this.isValid,
        submitState: submitState ?? this.submitState,
      );

  @override
  List<Object?> get props => [
        name,
        email,
        recordId,
        file,
        maxTry,
        pageSize,
        submitState,
      ];
}

sealed class VerificationFormSubmitState extends Equatable {
  const VerificationFormSubmitState();

  @override
  List<Object?> get props => [];
}

final class VerificationFormSubmitStateInitial
    extends VerificationFormSubmitState {
  const VerificationFormSubmitStateInitial();
}

final class VerificationFormSubmitStateInProgress
    extends VerificationFormSubmitState {
  const VerificationFormSubmitStateInProgress();
}

final class VerificationFormSubmitStateSuccess
    extends VerificationFormSubmitState {
  final SmartshieldVerification verification;
  const VerificationFormSubmitStateSuccess(this.verification);
}

final class VerificationFormSubmitStateFailure
    extends VerificationFormSubmitState {
  final dynamic err;
  final StackTrace st;
  const VerificationFormSubmitStateFailure(this.err, this.st);

  @override
  List<Object?> get props => [err, st];
}

final class VerificationFormSubmitStateTimeOut
    extends VerificationFormSubmitState {
  const VerificationFormSubmitStateTimeOut();
}
