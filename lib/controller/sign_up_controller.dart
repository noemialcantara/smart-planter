import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:hortijoy_mobile_app/models/file_model.dart';

class SignUpController extends GetxController {
  static SignUpController get instance => Get.find();
  FileModel? _imageFile;
  FileModel? get imageFile => _imageFile;

  void setImageFile(FileModel? file) {
    _imageFile = file;
    debugPrint("Updated ImageFile: ${imageFile!.filename}");
    update();
  }

  String? _username;
  String? get username => _username;
  void setName(String? text) {
    _username = text;
    debugPrint("Updated name: $username");
    update();
  }

  String? _email;
  String? get email => _email;
  void setEmail(String? text) {
    _email = text;
    // debugPrint("Updated email: $email");
    update();
  }

  String? _password;
  String? get password => _password;
  void setPassword(String? text) {
    _password = text;
    debugPrint("Updated password: $password");
    update();
  }

  String? _confirmPassword;
  String? get confirmPassword => _confirmPassword;
  void setConfirmPassword(String? text) {
    _confirmPassword = text;
    debugPrint("confirm password: $confirmPassword");
    update();
  }

  String? _mobileNumber;
  String? get mobileNumber => _mobileNumber;
  void setMobileNumber(String? text) {
    _mobileNumber = text;
    update();
  }

  String? _address;
  String? get address => _address;

  void setAddress(String? text) {
    _address = text;
    debugPrint("Updated address: $_address");
    update();
  }

  Future postSignUpDetails() async {
    var postUser = FirebaseFirestore.instance.collection("user").add({
      "name": username,
      "email": email.toString().toLowerCase(),
      "password": password,
      "address": address,
      "welcomeShown": false
    });

    return postUser;
    //uploadImageFile();
  }

  Future uploadImageFile() async {
    await FirebaseStorage.instance
        .ref('files/${imageFile!.filename}')
        .putData(imageFile!.fileBytes);
  }

  Future<bool> registerUser(String email, String password) async {
    try {
      var response = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return true;
    } catch (error) {
      if (error is FirebaseAuthException) {
        Get.showSnackbar(GetSnackBar(
          message: error.toString(),
        ));
      }
    }
    return false;
  }
}
