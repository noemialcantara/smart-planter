import 'package:dio/dio.dart';

class RequestResponse {
  String? id;
  bool? success;
  String? message;
  int? statusCode;
  int? httpStatus;
  String? tokenType;
  String? accessToken;
  String? userId;
  dynamic data;
  int? errorCode;

  RequestResponse(
      {this.id,
      this.success,
      this.message,
      this.statusCode,
      this.httpStatus,
      this.tokenType,
      this.accessToken,
      this.errorCode,
      this.userId,
      this.data});

  factory RequestResponse.fromJson(Map<String, dynamic> json) =>
      RequestResponse(
          id: json["id"],
          success: json['success'],
          message: json["message"],
          statusCode: json["status_code"],
          httpStatus: json['http_status'],
          tokenType: json["token_type"],
          accessToken: json["access_token"],
          userId: json["user_id"].toString(),
          data: json["data"]);

  // factory RequestResponse.error(Map<String, dynamic> json) => RequestResponse(
  //       success: json['success'],
  //       message: json['message'],
  //       statusCode: json["http_status"],
  //     );

  factory RequestResponse.dioErr(DioError e) {
    String message;
    try {
      message = e.response?.data['message'] ??
          e.error.toString() ??
          "Something wrong.";
    } catch (err) {
      message = e.toString();
    }
    return RequestResponse(
        success: false,
        message: message,
        statusCode: e.response!.data['http_status']);
  }
}
