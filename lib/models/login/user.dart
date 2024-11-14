import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());
String? role = 'CONDUCTOR';

class User {
  User(
      {this.uid,
      required this.role,
      required this.username,
      required this.password});

  String? uid;
  String role;
  String username;
  String password;

  factory User.fromJson(Map<String, dynamic> json) => User(
      uid: json["uid"],
      role: json['user_type'],
      username: json['username'],
      password: json["password"]);

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "role": role,
        "username": username,
        "password": password,
      };

  Map<String, dynamic> toLoginJson() => {
        "username": username,
        "password": password,
      };
}
