import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:injectable/injectable.dart';
import 'package:smartshield_document_validator/model/auth.dart';
import 'package:smartshield_document_validator/provider/httpclient.dart';

part 'auth.chopper.dart';

@Injectable()
@ChopperApi()
abstract class AuthService extends ChopperService {
  @FactoryMethod()
  static AuthService create(final AuthHttpClient client) =>
      _$AuthService(client);

  @FactoryConverter(
    request: _convertRequestSignIn,
    response: _convertResponseSignIn,
  )
  @POST(path: "/protocol/openid-connect/token")
  Future<TokenPair> signIn(@Body() final SignIn body);
}

Future<Request> _convertRequestSignIn(final Request request) async {
  final headers = request.headers;
  headers['Content-Type'] = 'application/x-www-form-urlencoded';
  final body = request.body as SignIn;
  final bodyMap = body.toJson();
  final bodyMapStr = <String, String>{};
  for (final entry in bodyMap.entries) {
    bodyMapStr[entry.key] = entry.value as String;
  }
  return request.copyWith(headers: headers, body: bodyMapStr);
}

Response<TokenPair> _convertResponseSignIn(final Response res) =>
    res.copyWith<TokenPair>(
      body: TokenPair.fromJson(
        jsonDecode(res.body as String) as Map<String, dynamic>,
      ),
    );
