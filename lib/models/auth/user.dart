import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  User(
      {required this.name,
      required this.phone,
      required this.email,
      required this.licenseNumber,
      required this.password,
      required this.referralCode});

  String name;
  String password;
  String email;
  String phone;
  String licenseNumber;
  String referralCode;

  factory User.fromJson(Map<String, dynamic> json) => User(
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      licenseNumber: json['license_number'],
      referralCode: json['referral_code'],
      password: json["password"]);

  Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
        "phone": phone,
        "password": password,
        "referral_code": referralCode,
      };

  Map<String, dynamic> registerToJson() => {
        "name": name,
        "email": email,
        "phone": phone,
        "password": password,
        "referral_code": referralCode,
      };
}
