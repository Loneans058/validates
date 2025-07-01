part of 'page.dart';

class _DialogMatch extends StatelessWidget {
  final String email;
  const _DialogMatch(this.email);
  @override
  Widget build(final BuildContext context) => AlertDialog(
        title: Column(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 50,
            ),
            const SizedBox(height: 20),
            Text(S.of(context).resutlverif),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(
                    text: S.of(context).docmatch,
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                ],
              ),
            ),
            Text(S.of(context).resultEmail(email)),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text((S.of(context).close)),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      );
}

class _DialogUnMatch extends StatelessWidget {
  final String email;
  const _DialogUnMatch(this.email);
  @override
  Widget build(final BuildContext context) => AlertDialog(
        title: Column(
          children: [
            const Icon(
              Icons.warning,
              color: Color.fromARGB(255, 228, 19, 12),
              size: 50,
            ),
            const SizedBox(height: 20),
            Text((S.of(context).resutlverif)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(
                    text: (S.of(context).docnotmatch),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            Text(S.of(context).resultEmail(email)),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text((S.of(context).close)),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      );
}

class _DialogTimeout extends StatelessWidget {
  final String email;
  const _DialogTimeout(this.email);
  @override
  Widget build(final BuildContext context) => AlertDialog(
        title: Column(
          children: [
            const Icon(
              Icons.mail_outlined,
              color: Color.fromARGB(255, 19, 235, 37),
              size: 50,
            ),
            const SizedBox(height: 20),
            Text(S.of(context).resultEmail(email)),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text((S.of(context).close)),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      );
}

class _DialogFailure extends StatelessWidget {
  final String message;
  final String email;
  const _DialogFailure(this.message, this.email);
  @override
  Widget build(final BuildContext context) => AlertDialog(
        title: const Column(
          children: [
            Icon(
              Icons.close,
              color: Color.fromARGB(255, 221, 23, 23),
              size: 50,
            ),
            SizedBox(height: 20),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(
                    text: (message),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            Text(S.of(context).resultEmail(email)),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text((S.of(context).close)),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      );
}
