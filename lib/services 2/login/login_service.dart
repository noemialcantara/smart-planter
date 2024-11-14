import 'package:hortijoy_mobile_app/models/login/user.dart';
import 'package:hortijoy_mobile_app/models/request_response.dart';
import 'package:http/http.dart' as http;
import 'package:hortijoy_mobile_app/resources/shared_pref_service.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class LoginService {
  Dio _dio = Dio();
  String baseUrl = "";
  LoginService() {
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
      // ..options.validateStatus = (status) {
      //   return status! < 400;
      // }
      ..interceptors.add(
        PrettyDioLogger(
          request: true,
          requestBody: true,
          requestHeader: true,
        ),
      );
    // ..interceptors.add(
    //   InterceptorsWrapper(
    //     onRequest: (RequestOptions options,
    //         RequestInterceptorHandler handler) async {
    //       print(
    //           '--------------------ONR REQUEST DIO CODE-----------------------------------');
    //       print('REQUEST[${options.method}] => PATH: ${options.path}');
    //       try {
    //         var token = await SharedPreferenceService.getBearerToken();

    //         if (token != null) {
    //           options.headers.putIfAbsent('Authorization', () => token);
    //         } else {}
    //       } catch (e) {
    //       } finally {}

    //       handler.next(options);
    //     },
    //   ),
    // );
  }

  /*
  * Name: Login function
  * Description: To authenticate the user in the app
  */
  Future<RequestResponse> login(User user) async {
    String url = '$baseUrl/auth/login';
    Map<String, dynamic> data = user.toJson();
    try {
      Response response = await _dio.post(url, data: data);
      print('-----------RESPONSE DATA------------');
      print(response.data);
      return RequestResponse.fromJson(response.data);
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response!.data);
        // return RequestResponse.error(e.response!.data);
        return RequestResponse.dioErr(e);
      } else {
        return RequestResponse.dioErr(e);
      }
    }
  }
}
