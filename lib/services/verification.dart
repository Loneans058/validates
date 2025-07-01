import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:http/http.dart' show MultipartFile;
import 'package:injectable/injectable.dart';
import 'package:smartshield_document_validator/model/verification.dart';
import 'package:smartshield_document_validator/provider/httpclient.dart';

part 'verification.chopper.dart';

@Injectable()
@ChopperApi()
abstract class SmartshieldVerificationService extends ChopperService {
  @FactoryMethod()
  static SmartshieldVerificationService create(final HttpClient client) =>
      _$SmartshieldVerificationService(client);

  @FactoryConverter(
    response: _convertResponseSmartshieldVerification,
  )
  @POST(path: "/interactive/verify")
  @Multipart()
  Future<SmartshieldVerification> verify(
    @Part() final String name,
    @Part() final String email,
    @Part() final String recordId,
    @Part("before.metaData") final String metaData,
    @PartFile("before.file") final MultipartFile file,
  );
}

Response<SmartshieldVerification> _convertResponseSmartshieldVerification(
  final Response res,
) =>
    res.copyWith(
      body: SmartshieldVerification.fromJson(
        jsonDecode(res.body as String) as Map<String, dynamic>,
      ),
    );
