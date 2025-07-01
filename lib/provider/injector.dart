import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:smartshield_document_validator/provider/injector.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<GetIt> configureDependencies() => getIt.init();
