import 'package:flutter/cupertino.dart';
import 'package:hortijoy_mobile_app/resources/shared_pref_service.dart';
import 'package:flutter/material.dart';
import 'package:hortijoy_mobile_app/resources/base.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HttpErrorRequestHandler {
  static handleHttpError(HttpErrorCode errorCode, BuildContext context) async {
    switch (errorCode) {
      case HttpErrorCode.Http401:
        SharedPreferenceService.handleLogOut();
        Navigator.of(context).popUntil((r) => r.isFirst);
        Navigator.pushReplacementNamed(context, Routes.SPLASH_SCREEN);
        // CLEAR DATA
        var sharedPrefs = await SharedPreferences.getInstance();
        await sharedPrefs.clear();
        break;
      case HttpErrorCode.Http403:
        Navigator.of(context).popUntil((r) => r.isFirst);
        Navigator.pushReplacementNamed(context, Routes.SPLASH_SCREEN);
        break;
      default:
        return;
    }
  }
}

enum HttpErrorCode { Http401, Http403 }
