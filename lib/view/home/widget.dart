part of 'page.dart';

class _NameField extends StatelessWidget {
  const _NameField();
  @override
  Widget build(final BuildContext context) =>
      BlocBuilder<VerificationFormCubit, VerificationFormState>(
        builder: _builder,
      );

  Widget _builder(
    final BuildContext context,
    final VerificationFormState state,
  ) =>
      TextFormField(
        initialValue: state.name.value,
        decoration: InputDecoration(
          labelText: S.of(context).name,
          errorText: _errorHandler(context, state.name.displayError),
        ),
        onChanged: (final text) =>
            context.read<VerificationFormCubit>().name = text,
      );

  String? _errorHandler(
    final BuildContext context,
    final VerificationFormNameValidationError? e,
  ) {
    switch (e) {
      case VerificationFormNameValidationError.empty:
        return S.of(context).errorInputFieldEmpty;
      default:
        return null;
    }
  }
}

class _EmailsField extends StatelessWidget {
  const _EmailsField();
  @override
  Widget build(final BuildContext context) =>
      BlocBuilder<VerificationFormCubit, VerificationFormState>(
        builder: _builder,
      );

  Widget _builder(
    final BuildContext context,
    final VerificationFormState state,
  ) =>
      TextField(
        decoration: InputDecoration(
          labelText: S.of(context).email,
          errorText: _errorHandler(context, state.email.displayError),
        ),
        onChanged: (final text) =>
            context.read<VerificationFormCubit>().email = text,
      );

  String? _errorHandler(
    final BuildContext context,
    final VerificationFormEmailValidationError? e,
  ) {
    if (e == null) {
      return null;
    }
    switch (e) {
      case VerificationFormEmailValidationError.empty:
        return S.of(context).errorInputFieldEmpty;
      case VerificationFormEmailValidationError.invalid:
        return S.of(context).errorEmailInvalid;
    }
  }
}

class _RecordIdField extends StatelessWidget {
  const _RecordIdField();
  @override
  Widget build(final BuildContext context) =>
      BlocBuilder<VerificationFormCubit, VerificationFormState>(
        builder: _builder,
      );

  Widget _builder(
    final BuildContext context,
    final VerificationFormState state,
  ) =>
      TextField(
        decoration: InputDecoration(
          labelText: S.of(context).recordId,
          errorText: _errorHandler(context, state.recordId.displayError),
        ),
        onChanged: (final text) =>
            context.read<VerificationFormCubit>().recordId = text,
      );

  String? _errorHandler(
    final BuildContext context,
    final VerificationFormRecordIdValidationError? e,
  ) {
    switch (e) {
      case VerificationFormRecordIdValidationError.empty:
        return S.of(context).errorInputFieldEmpty;
      case VerificationFormRecordIdValidationError.notFound:
        return S.of(context).errorRecordIdNotFound;
      default:
        return null;
    }
  }
}

class _Button extends StatelessWidget {
  const _Button();
  @override
  Widget build(final BuildContext context) =>
      BlocConsumer<VerificationFormCubit, VerificationFormState>(
        listener: _verification,
        builder: _builder,
      );

  Widget _builder(
    final BuildContext context,
    final VerificationFormState state,
  ) {
    late final Widget child;
    switch (state.submitState) {
      case VerificationFormSubmitStateInitial():
        child = Center(
          child: ElevatedButton(
            onPressed: context.read<VerificationFormCubit>().submit,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(
                horizontal: 200, // Modified to 300px
                vertical: 20,
              ),
              backgroundColor: Colors.white,
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: Colors.blue),
              ),
            ),
            child: const Text(
              'Verifikasi sertifikat kapal dengan Blockchain SmartShield',
            ),
          ),
        );
        break;
      case VerificationFormSubmitStateInProgress():
        child = const Center(child: CircularProgressIndicator());
        break;
      case VerificationFormSubmitStateSuccess():
        child = Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 200),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 200,
                  vertical: 20, // Modified to 40px
                ),
                backgroundColor: Colors.green,
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('Sukses'),
            ),
          ),
        );
        break;
      case VerificationFormSubmitStateFailure():
        child = Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 200),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 200,
                  vertical: 20, // Modified to 40px
                ),
                backgroundColor: Colors.red,
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('Coba Lagi'),
            ),
          ),
        );
        break;
      default:
        child = const SizedBox.shrink();
        break;
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (
        final Widget child,
        final Animation<double> animation,
      ) =>
          SlideTransition(
        position: Tween(
          begin: const Offset(1.0, 1.0),
          end: const Offset(0.0, 0.0),
        ).animate(animation),
        child: child,
      ),
      child: child,
    );
  }

  void _verification(
    final BuildContext context,
    final VerificationFormState state,
  ) {
    final submitState = state.submitState;
    switch (submitState) {
      case VerificationFormSubmitStateInitial():
        break;
      case VerificationFormSubmitStateSuccess():
        if (submitState.verification.valid) {
          showDialog(
            context: context,
            builder: (final BuildContext context) =>
                _DialogMatch(state.email.value),
          );
        } else {
          showDialog(
            context: context,
            builder: (final BuildContext context) =>
                _DialogUnMatch(state.email.value),
          );
        }
        break;
      case VerificationFormSubmitStateFailure():
        final err = submitState.err;

        if (err is EZError) {
          if (err.code == 5) {
            showDialog(
              context: context,
              builder: (final BuildContext context) => _DialogFailure(
                S.of(context).errorRecordIdNotFound,
                state.email.value,
              ),
            );
          } else {
            showDialog(
              context: context,
              builder: (final BuildContext context) =>
                  _DialogFailure(state.email.value, err.message),
            );
          }
        } else if (err is VerificationFormRecordIdValidationError) {
          showDialog(
            context: context,
            builder: (final BuildContext context) =>
                _DialogFailure(state.email.value, err.toString()),
          );
        }
        break;
      case VerificationFormSubmitStateTimeOut():
        showDialog(
          context: context,
          builder: (final BuildContext context) =>
              _DialogTimeout(state.email.value),
        );
        break;
      default:
    }
  }
}

class _VerifyTopButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _VerifyTopButton(this.onPressed);
  @override
  Widget build(final BuildContext context) => ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 70,
            vertical: 20, // Modified to 40px
          ),
          backgroundColor: Colors.green,
          textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: Text((S.of(context).docverify)),
      );
}

class _BKILogo extends StatelessWidget {
  const _BKILogo();
  @override
  Widget build(final BuildContext context) => Image.asset(
        Assets.images.bkilogo.path,
        height: MediaQuery.of(context).size.height * .3,
      );
}

class _SmartShieldLogo extends StatelessWidget {
  const _SmartShieldLogo();
  @override
  Widget build(final BuildContext context) => Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * .14,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.asset(Assets.images.smartshield1.path),
          ),
        ),
      );
}

class _FilePickerWidget extends StatefulWidget {
  const _FilePickerWidget();
  @override
  _FilePickerWidgetState createState() => _FilePickerWidgetState();
}

class _FilePickerWidgetState extends State<_FilePickerWidget> {
  String? _fileName;
  int? _fileSize;

  void _openFilePicker(final BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result != null) {
      final file = result.files.first;
      final fileBytes = file.bytes;
      final fileName = file.name;
      if (!context.mounted) {
        return;
      }
      context.read<VerificationFormCubit>().file = file.bytes;
      setState(() {
        _fileName = fileName;
        _fileSize = fileBytes?.length;
      });
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              _openFilePicker(context);
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
              child: DottedBorder(
                borderType: BorderType.RRect,
                radius: const Radius.circular(10),
                dashPattern: const [10, 4],
                strokeCap: StrokeCap.round,
                color: Colors.blue.shade400,
                child: Container(
                  width: 250,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50.withOpacity(.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open, color: Colors.blue, size: 40),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        'Unggah file Anda',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color.fromARGB(255, 63, 54, 54),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (_fileName != null)
            Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade50.withOpacity(.3),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Nama file: $_fileName', textAlign: TextAlign.center),
                  const SizedBox(height: 5),
                  Text(
                    'Ukuran file: ${(_fileSize! / (1024 * 1024)).toStringAsFixed(2)} MB',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
