import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:smartshield_document_validator/model/httperror.dart';
import 'package:smartshield_document_validator/provider/config.dart';
import 'package:smartshield_document_validator/provider/injector.dart';
import 'package:smartshield_document_validator/provider/session.dart';
import 'package:synchronized/synchronized.dart';

@Singleton()
final class AuthHttpClient extends ChopperClient {
  @FactoryMethod()
  static AuthHttpClient create(final Config config) => AuthHttpClient(
        baseUrl: Uri.parse(config.ssoUrl),
        converter: const JsonConverter(),
        errorConverter: const _AuthErrorConverter(),
      );
  AuthHttpClient({super.baseUrl, super.converter, super.errorConverter});
}

@Singleton()
final class HttpClient extends ChopperClient {
  @FactoryMethod()
  static HttpClient create(final Config config) => HttpClient(
        baseUrl: Uri.parse(config.url),
        converter: const JsonConverter(),
        errorConverter: const _ErrorConverter(),
        authenticator: const AppAuthenticator(),
        interceptors: [const AuthInterceptor()],
      );
  HttpClient({
    super.baseUrl,
    super.converter,
    super.errorConverter,
    super.authenticator,
    super.interceptors,
  });
}

class _AuthErrorConverter implements ErrorConverter {
  const _AuthErrorConverter();
  @override
  FutureOr<Response> convertError<BodyType, InnerType>(
    final Response response,
  ) {
    try {
      final body = jsonDecode(response.body);
      return response.copyWith<AuthHttpError>(
        body: AuthHttpError.fromJson(body),
      );
    } catch (_, __) {
      return response;
    }
  }
}

class _ErrorConverter implements ErrorConverter {
  const _ErrorConverter();
  @override
  FutureOr<Response> convertError<BodyType, InnerType>(
    final Response response,
  ) {
    try {
      final body = jsonDecode(response.body);
      return response.copyWith<HttpError>(body: HttpError.fromJson(body));
    } catch (_, __) {
      return response;
    }
  }
}

class AppAuthenticator implements Authenticator {
  static final lock = Lock();
  const AppAuthenticator();
  @override
  FutureOr<Request?> authenticate(
    final Request request,
    final Response response, [
    final Request? originalRequest,
  ]) async {
    // 401
    if (response.statusCode == HttpStatus.unauthorized) {
      // Trying to update token only 1 time
      if (request.headers['Retry-Count'] != null) {
        return null;
      }

      try {
        final access = await lock.synchronized(() async {
          try {
            return await getIt<Session>().refreshAccessToken();
          } catch (err, st) {
            debugPrint(err.toString());
            debugPrintStack(stackTrace: st);
            return null;
          }
        });

        if (access == null) {
          return null;
        }

        return applyHeaders(
          request,
          {
            HttpHeaders.authorizationHeader: access,
            // Setting the retry count to not end up in an infinite loop
            // of unsuccessful updates
            'Retry-Count': '1',
          },
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  @override
  AuthenticationCallback? get onAuthenticationFailed => null;

  @override
  AuthenticationCallback? get onAuthenticationSuccessful => null;
}

class AuthInterceptor implements Interceptor {
  const AuthInterceptor();
  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
    final Chain<BodyType> chain,
  ) async {
    final request = chain.request;
    final updatedRequest = applyHeader(
      request,
      HttpHeaders.authorizationHeader,
      getIt<Session>().accessToken(),
      override: false,
    );
    return await chain.proceed(updatedRequest);
  }
}
