import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';
import 'package:smartshield_document_validator/routes.gr.dart';

@Singleton()
@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends $AppRouter {
  @override
  List<AutoRoute> get routes => [AutoRoute(path: '/', page: HomeRoute.page)];
}
