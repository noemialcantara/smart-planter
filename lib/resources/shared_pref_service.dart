import 'dart:async';

import 'package:hortijoy_mobile_app/models/auth/user.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceService {
  static setLoggedInUser(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user', userId.toString());
  }

  static Future<String> getLoggedInUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user') ?? '';
  }

  static Future<String> getLoggedInUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('email') ?? '';
  }

  static setLoggedInUserEmail(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('email', email.toString());
  }

  static setAddedPlanterUID(String uid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString("uid", uid.toString());
  }

  static Future getAddedPlanterUID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('uid');
  }

// * INFO Determine if the planter is already profiled to be passed on planter profile
  static setIsAlreadyProfiled(String isProfiled) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString("alreadyProfiled", isProfiled.toString());
  }

  static Future getIsAlreadyProfiled() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('alreadyProfiled');
  }

  static Future<bool> setIsFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isFirstTime') ?? true;
  }

  static Future<bool> getIsFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isFirstTime') ?? true;
  }

  static setBearerToken(String tokenType, String accessToken) async {
    if (tokenType != null && accessToken != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('bearer_token', '$tokenType $accessToken');
    }
  }

  static setUserId(String userId) async {
    if (userId != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('user_id', '$userId');
    }
  }

  static Future<String> getBearerToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('bearer_token') ?? "";
  }

  static Future<String> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id') ?? "";
  }

  static setUser(User userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user_data', userToJson(userData));
  }

  static getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userDataString = prefs.getString('user_data') ?? "";
    if (userDataString.isNotEmpty) {
      try {
        return userFromJson(userDataString);
      } catch (e) {
        return userDataString;
      }
    }
    return userDataString;
  }

  static setPassword(String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('password', password);
  }

  static Future<String> getPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('password') ?? "";
  }

  static handleLogOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('getLoggedInUserEmail');
    // await prefs.clear();
  }

  static Future<bool> isGpsUsed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_gps_used') ?? false;
  }

  static Future<bool> setIsGpsUsed(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool('is_gps_used', value);
  }
}
