import 'dart:io';
import 'package:hortijoy_mobile_app/models/login/user.dart';
import 'package:hortijoy_mobile_app/models/request_response.dart';
import 'package:hortijoy_mobile_app/services/login/login_service.dart';

class Repository {
  LoginService _apiService = LoginService();

  /*
  * Name: Login function
  * Description: To authenticate the user in the app
  */
  Future<RequestResponse> login(User user) {
    return _apiService.login(user);
  }
}
