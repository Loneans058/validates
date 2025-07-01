import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';

@Singleton()
final class Config {
  final String env;
  final String url;
  final String ssoUrl;
  final String ssoClientId;

  Config({
    required this.env,
    required this.url,
    required this.ssoUrl,
    required this.ssoClientId,
  });

  @preResolve
  @FactoryMethod()
  static Future<Config> create() async {
    if (kIsWeb) {
      if (kDebugMode) {
        await dotenv.load();
      } else {
        await dotenv.load(fileName: 'env');
      }
    } else {
      await dotenv.load();
    }
    final env = dotenv.get('ENV');
    final url = dotenv.get('URL');
    final ssoUrl = dotenv.get('SSO_URL');
    final ssoClientId = dotenv.get('SSO_CLIENT_ID');
    return Config(
      env: env,
      url: url,
      ssoUrl: ssoUrl,
      ssoClientId: ssoClientId,
    );
  }
}
