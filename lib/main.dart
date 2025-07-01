import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:smartshield_document_validator/generated/l10n.dart';
import 'package:smartshield_document_validator/provider/injector.dart';
import 'package:smartshield_document_validator/routes.dart';

part 'theme.dart';

Future<void> main() async {
  debugPrint("ensure widget flutter binding initialized");
  WidgetsFlutterBinding.ensureInitialized();

  await configureDependencies();
  await getIt.allReady();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(final BuildContext context) => MaterialApp.router(
        title: 'SmartShield Document Validator',
        localizationsDelegates: const [
          GlobalWidgetsLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
          S.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        locale: const Locale("id", ""),
        theme: _theme,
        routerConfig: getIt<AppRouter>().config(),
      );
}
