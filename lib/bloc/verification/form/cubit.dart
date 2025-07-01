import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:http/http.dart';
import 'package:smartshield_document_validator/model/httperror.dart';
import 'package:smartshield_document_validator/model/verification.dart';
import 'package:smartshield_document_validator/provider/injector.dart';
import 'package:smartshield_document_validator/provider/logger.dart';
import 'package:smartshield_document_validator/provider/session.dart';
import 'package:smartshield_document_validator/services/verification.dart';

part 'model.dart';
part 'state.dart';

class VerificationFormCubit extends Cubit<VerificationFormState> {
  VerificationFormCubit() : super(const VerificationFormState());

  set name(final String value) {
    final name = VerificationFormName.dirty(value: value);
    emit(
      state.copyWith(
        name: name,
        isValid: Formz.validate([name, state.email, state.recordId]),
      ),
    );
  }

  set email(final String value) {
    final email = VerificationFormEmail.dirty(value);
    emit(
      state.copyWith(
        email: email,
        isValid: Formz.validate([state.name, email, state.recordId]),
      ),
    );
  }

  set recordId(final String value) {
    final recordId = VerificationFormRecordId.dirty(value: value);
    emit(
      state.copyWith(
        recordId: recordId,
        isValid: Formz.validate([state.name, state.email, recordId]),
      ),
    );
  }

  set file(final Uint8List? value) {
    final file = VerificationFormFile.dirty(value);
    emit(
      state.copyWith(
        file: file,
        isValid:
            Formz.validate([state.name, state.email, state.recordId, file]),
      ),
    );
  }

  Future<void> submit() async {
    final name = VerificationFormName.dirty(value: state.name.value);
    final email = VerificationFormEmail.dirty(state.email.value);
    final recordId =
        VerificationFormRecordId.dirty(value: state.recordId.value);
    final file = VerificationFormFile.dirty(state.file.value);
    emit(
      state.copyWith(
        name: name,
        email: email,
        recordId: recordId,
        file: file,
        isValid: Formz.validate([name, email, recordId, file]),
      ),
    );
    if (!state.isValid) {
      return;
    }
    try {
      emit(
        state.copyWith(
          submitState: const VerificationFormSubmitStateInProgress(),
        ),
      );
      //API call
      await getIt<SessionManager>().signIn("test@chainsmart.id", "test1234");
      final res = await getIt<SmartshieldVerificationService>().verify(
        state.name.value,
        state.email.value,
        state.recordId.value,
        "{}",
        MultipartFile.fromBytes(
          "before.file",
          file.value!,
          filename: "Boat 3.pdf",
        ),
      );
      if (state.name.value.length > 10) {
        await Future.delayed(const Duration(seconds: 10));
        emit(
          state.copyWith(
            submitState: const VerificationFormSubmitStateTimeOut(),
          ),
        );
        await Future.delayed(const Duration(seconds: 5));
        emit(
          state.copyWith(
            submitState: const VerificationFormSubmitStateInitial(),
          ),
        );
        return;
      }
      //API success call
      if (res.err != null) {
        if (res.err!.code == 404) {
          emit(
            state.copyWith(
              recordId: VerificationFormRecordId.dirty(
                externalError: VerificationFormRecordIdValidationError.notFound,
                value: state.recordId.value,
              ),
              submitState:
                  VerificationFormSubmitStateFailure(res.err, StackTrace.empty),
              isValid: Formz.validate([name, email, recordId, file]),
            ),
          );
          await Future.delayed(const Duration(seconds: 5));
          emit(
            state.copyWith(
              submitState: const VerificationFormSubmitStateInitial(),
            ),
          );
          return;
        }
        emit(
          state.copyWith(
            submitState:
                VerificationFormSubmitStateFailure(res.err, StackTrace.empty),
            isValid: Formz.validate([name, email, recordId, file]),
          ),
        );
        await Future.delayed(const Duration(seconds: 5));
        emit(
          state.copyWith(
            submitState: const VerificationFormSubmitStateInitial(),
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          submitState: VerificationFormSubmitStateSuccess(res),
        ),
      );
      await Future.delayed(const Duration(seconds: 5));
      //reset form
      emit(
        state.copyWith(
          submitState: const VerificationFormSubmitStateInitial(),
        ),
      );
    } on HttpError catch (err, st) {
      logger.e(err.toString(), error: err, stackTrace: st);
      if (err.code == 404) {
        emit(
          state.copyWith(
            recordId: VerificationFormRecordId.dirty(
              externalError: VerificationFormRecordIdValidationError.notFound,
              value: state.recordId.value,
            ),
            submitState: VerificationFormSubmitStateFailure(err, st),
            isValid: Formz.validate([name, email, recordId, file]),
          ),
        );
      } else {
        emit(
          state.copyWith(
            submitState: VerificationFormSubmitStateFailure(err, st),
            isValid: Formz.validate([name, email, recordId, file]),
          ),
        );
      }
      await Future.delayed(const Duration(seconds: 5));
      emit(
        state.copyWith(
          submitState: const VerificationFormSubmitStateInitial(),
        ),
      );
    } catch (err, st) {
      logger.e(err.toString(), error: err, stackTrace: st);
      emit(
        state.copyWith(
          submitState: VerificationFormSubmitStateFailure(err, st),
          isValid: Formz.validate([name, email, recordId, file]),
        ),
      );
      await Future.delayed(const Duration(seconds: 5));
      emit(
        state.copyWith(
          submitState: const VerificationFormSubmitStateInitial(),
        ),
      );
    } finally {
      await getIt<SessionManager>().signOut();
    }
  }
}
