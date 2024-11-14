import 'package:hortijoy_mobile_app/models/register/register.dart';
import 'package:hortijoy_mobile_app/models/request_response.dart';
import 'package:http/http.dart' as http;
import 'package:hortijoy_mobile_app/resources/shared_pref_service.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class RegisterService {
  Dio _dio = Dio();
  String baseUrl =
      "https://2026-155-137-108-68.ap.ngrok.io/api/v1"; // create constants folder
  RegisterService() {
    //NOTE: FOR DEPLOYED API SERVER ONLY
    // (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
    //     (HttpClient client) {
    //   client.badCertificateCallback =
    //       (X509Certificate cert, String host, int port) => true;

    //   return client;
    // };

    _dio
      ..options.connectTimeout = 60000
      ..options.receiveTimeout = 60000
      ..options.headers = {'Content-Type': 'application/json; charset=utf-8'}
      ..options.followRedirects = false
      ..options.validateStatus = (status) {
        return status! < 400;
      }
      ..interceptors.add(
        PrettyDioLogger(
          requestBody: true,
          requestHeader: true,
        ),
      )
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (RequestOptions options,
              RequestInterceptorHandler handler) async {
            try {
              var token = await SharedPreferenceService.getBearerToken();

              if (token != null) {
                options.headers.putIfAbsent('Authorization', () => token);
              } else {}
            } catch (e) {} finally {}

            handler.next(options);
          },
        ),
      );
  }

  /*
  * Name: Login function
  * Description: To authenticate the user in the app
  */
  Future<RequestResponse> register(User user) async {
    String url = '$baseUrl/passenger/register';
    Map<String, dynamic> data = user.registerToJson();
    try {
      Response response = await _dio.post(url, data: data);
      return RequestResponse.fromJson(response.data);
    } on DioError catch (e) {
      return RequestResponse.dioErr(e);
    }
  }
}
