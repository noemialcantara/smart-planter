import 'dart:io';
import 'package:hortijoy_mobile_app/models/register/register.dart';
import 'package:hortijoy_mobile_app/models/request_response.dart';
import 'package:hortijoy_mobile_app/services/register/register_service.dart';

class Repository {
  final _apiService = RegisterService();

  /*
  * Name: Login function
  * Description: To authenticate the user in the app
  */
  Future<RequestResponse> register(User user) => _apiService.register(user);
}
