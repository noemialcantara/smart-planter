import 'package:hortijoy_mobile_app/models/request_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NetworkUtil {
  static Future<RequestResponse> handleNetworkResponse(
      RequestResponse response) async {
    if (response.success ?? false) {
      return response;
    }

    RequestResponse resp = response;

    switch (resp.errorCode) {
      case 400:
        resp.message = "Please make sure all of your info are correct";
        break;

      case 401:
        resp.message = "Not logged in. Please log in.";
        var sharedPrefs = await SharedPreferences.getInstance();
        await sharedPrefs.clear();
        break;

      case 403:
        resp.message = "Session expired, please log in.";
        break;

      default:
        if ((resp.errorCode ?? 401) >= 500) {
          resp.message = "[${resp.errorCode}] Server error.";
        } else {}
    }

    return resp;
  }
}
