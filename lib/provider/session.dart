import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:openid_client/openid_client.dart';
import 'package:smartshield_document_validator/model/auth.dart';
import 'package:smartshield_document_validator/provider/config.dart';
import 'package:smartshield_document_validator/provider/injector.dart';
import 'package:smartshield_document_validator/provider/logger.dart';
import 'package:smartshield_document_validator/services/auth.dart';
import 'package:smartshield_document_validator/services/verification.dart';

class ExceptionInvalidCredential implements Exception {
  String cause;
  ExceptionInvalidCredential(this.cause);
}

class Session {
  final Credential _credential;
  String _accessToken;
  UserInfo userInfo;

  Session(
    final String accessToken,
    final Credential credential,
  )   : _accessToken = accessToken,
        _credential = credential,
        userInfo = UserInfo.fromJson({});

  static Future<void>? _refreshSessionFuture;
  String accessToken() => "Bearer $_accessToken";

  Future<String> refreshAccessToken() async {
    if (_refreshSessionFuture != null) await _refreshSessionFuture;
    if (shouldRefreshAccessToken()) {
      Completer<void> completer;
      if (_refreshSessionFuture == null) {
        completer = Completer();
        _refreshSessionFuture = completer.future;
        try {
          final res = await _credential.getTokenResponse();
          _accessToken = res.accessToken!;
        } catch (error, st) {
          Future.delayed(
            Duration.zero,
            () => getIt.unregister<Session>(),
          );
          logger.e(error.toString(), error: error, stackTrace: st);
          return "Bearer ";
        } finally {
          completer.complete();
          _refreshSessionFuture = null;
        }
      } else {
        await _refreshSessionFuture;
      }
    }
    return "Bearer $_accessToken";
  }

  bool shouldRefreshAccessToken() => true;

  Future<void> refreshData() => loadUserInfo();

  Future<void> loadUserInfo() async =>
      userInfo = await _credential.getUserInfo();
}

@Singleton()
class SessionManager {
  final Config config;
  final AuthService svc;
  final SmartshieldVerificationService listenerService;

  @FactoryMethod()
  static SessionManager create(
    final Config config,
    final AuthService svc,
    final SmartshieldVerificationService listenerService,
  ) =>
      SessionManager(config, svc, listenerService);

  SessionManager(
    this.config,
    this.svc,
    this.listenerService,
  );
  bool get hasSession => getIt.isRegistered<Session>();
  Future<void> signIn(final String email, final String password) async {
    final issuer = await Issuer.discover(Uri.parse(config.ssoUrl));
    final client = Client(issuer, config.ssoClientId);
    final param = SignIn(
      grantType: 'password',
      clientId: config.ssoClientId,
      username: email,
      password: password,
      scope: 'openid',
    );
    final tokenPair = await svc.signIn(param);
    final credential = client.createCredential(
      accessToken: tokenPair.accessToken,
      refreshToken: tokenPair.refreshToken,
    );
    final session = Session(tokenPair.accessToken, credential);
    getIt.registerSingleton(session);
    await session.refreshData();
  }

  Future<void> signOut() async {
    try {
      await getIt.unregister<Session>();
    } catch (err, st) {
      debugPrint(err.toString());
      debugPrintStack(stackTrace: st);
      logger.e(err.toString(), error: err, stackTrace: st);
    }
  }
}
