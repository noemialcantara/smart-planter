import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hortijoy_mobile_app/screens/home/home_page_body.dart';
import 'package:hortijoy_mobile_app/screens/login/login_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hortijoy_mobile_app/resources/my_button.dart';
import 'package:hortijoy_mobile_app/controller/flow_controller.dart';
import 'package:hortijoy_mobile_app/controller/sign_up_controller.dart';
import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hortijoy_mobile_app/custom_widgets/custom_circular_icons.dart';
import 'package:http/http.dart' as http;

class SignUpOne extends StatefulWidget {
  const SignUpOne({super.key});

  @override
  State<SignUpOne> createState() => _SignUpOneState();
}

class _SignUpOneState extends State<SignUpOne> {
  final emailController = TextEditingController().obs;
  final passwordController = TextEditingController().obs;
  final confirmPasswordController = TextEditingController().obs;
  final nameController = TextEditingController().obs;
  final addressController = TextEditingController().obs;
  SignUpController signUpController = Get.put(SignUpController());
  FlowController flowController = Get.put(FlowController());
  bool _isLoading = false;
  bool _passwordMatched = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  String _confirmPassword = "";
  String _errorMessage = "";
  String _passwordErrorMessage = "";

  Future<bool> checkIfEmailInUse(String emailAddress) async {
    try {
      final list =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(emailAddress);

      if (list.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      return true;
    }
  }

  void _startLoading() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: signUpController.email.toString(),
          password: signUpController.password.toString());

      flowController.setFlow(2);
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (e.code == 'email-already-in-use') {
        // Display an error modal if the email is already in use
        _showErrorModal(
            context, 'This email is already in use. Please try another.');
      } else if (e.code == 'invalid-email') {
        // Handle invalid email case
        _showErrorModal(context, 'The email address is not valid.');
      } else if (e.code == 'weak-password') {
        // Handle weak password case
        _showErrorModal(context,
            'Your password is too weak. Please choose a stronger one.');
      } else {
        // Default error message
        _showErrorModal(context, e.message.toString());
      }
    }

    // signUpController.postSignUpDetails();

    // UserCredential? userCredential = await FirebaseAuth.instance
    //     .signInWithEmailAndPassword(
    //         email: signUpController.email.toString(),
    //         password: signUpController.password.toString());
    // if (userCredential != null) {
    //   setState(() {
    //   });

    // _navigateToHomeScreen(context);
  }

  void _showErrorModal(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the modal
              },
            ),
          ],
        );
      },
    );
  }

  _navigateToHomeScreen(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const HomeScreenBody()));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        child: const Center(child: CircularProgressIndicator()),
      );
    } else {
      return _buildDisplaySignUp(context);
    }
  }

  Material _buildDisplaySignUp(BuildContext context) {
    return Material(
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 0, 30, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "SIGN UP",
                  style: GoogleFonts.openSans(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: emailController.value,
                    onChanged: (value) {
                      validateEmail(value);
                      signUpController.setEmail(value);
                    },
                    onSubmitted: (value) {
                      signUpController.setEmail(value);
                    },
                    cursorColor: HexColor("#4f4f4f"),
                    decoration: InputDecoration(
                      hintText: "Email",
                      contentPadding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                      hintStyle: GoogleFonts.openSans(
                        fontSize: 15,
                        color: HexColor("#8d8d8d"),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                    child: Text(
                      _errorMessage,
                      style: GoogleFonts.openSans(
                        fontSize: 12,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  TextField(
                    onChanged: (value) {
                      validatePassword(value);
                      signUpController.setPassword(value);
                    },
                    onSubmitted: (value) {
                      signUpController.setPassword(value);
                    },
                    obscureText: !_isPasswordVisible,
                    controller: passwordController.value,
                    cursorColor: HexColor("#4f4f4f"),
                    decoration: InputDecoration(
                      hintText: "Password",
                      contentPadding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                      hintStyle: GoogleFonts.openSans(
                        fontSize: 15,
                        color: HexColor("#8d8d8d"),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                    child: Text(
                      _passwordErrorMessage,
                      style: GoogleFonts.openSans(
                        fontSize: 12,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  TextField(
                    onChanged: (value) {
                      signUpController.setConfirmPassword(value);
                      setState(() {
                        _confirmPassword = value;
                      });
                      checkIfMatched();
                    },
                    onSubmitted: (value) {
                      signUpController.setConfirmPassword(value);
                    },
                    controller: confirmPasswordController.value,
                    keyboardType: TextInputType.text,
                    obscureText: !_isConfirmPasswordVisible,
                    cursorColor: HexColor("#4f4f4f"),
                    decoration: InputDecoration(
                      hintText: "Confirm Password",
                      contentPadding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                      hintStyle: GoogleFonts.openSans(
                        fontSize: 15,
                        color: HexColor("#8d8d8d"),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                    child: Text(
                      _passwordErrorMessage,
                      style: GoogleFonts.openSans(
                        fontSize: 12,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  GestureDetector(
                    child: Container(
                      height: 42,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: Center(
                          child: Text(
                        'Next',
                        style: GoogleFonts.openSans(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      )),
                    ),
                    onTap: () async {
                      // flowController.setFlow(2);
                      if (_passwordMatched) {
                        if (signUpController.email != null &&
                            signUpController.password != null) {
                          setState(() {
                            _isLoading = true;
                          });
                          bool isRegistered = await checkIfEmailInUse(
                              signUpController.email ?? "");
                          debugPrint(isRegistered.toString());
                          if (!isRegistered) {
                            _startLoading();
                          } else {
                            setState(() {
                              _isLoading =
                                  false; // Stop loading if email is already registered
                              _errorMessage = "This email is already taken";
                            });
                          }
                        } else {
                          AnimatedSnackBar.material(
                            'Please fill up all the fields',
                            type: AnimatedSnackBarType.error,
                            mobileSnackBarPosition: MobileSnackBarPosition
                                .bottom, // Position of snackbar on mobile devices
                            desktopSnackBarPosition: DesktopSnackBarPosition
                                .bottomCenter, // Position of snackbar on desktop devices
                          ).show(context);
                        }
                      }
                    },
                  ),
                  SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Already have an account?",
                          style: GoogleFonts.openSans(
                            fontSize: 15,
                            color: HexColor("#8d8d8d"),
                          )),
                      Expanded(
                          child: TextButton(
                        child: Text(
                          "Sign In",
                          style: GoogleFonts.openSans(
                            fontSize: 15,
                            color: HexColor("#44564a"),
                          ),
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        ),
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void validateEmail(String val) {
    if (val.isEmpty) {
      setState(() {
        _errorMessage = "Email can not be empty";
      });
    } else {
      setState(() {
        _errorMessage = "";
      });
    }
  }

  void validatePassword(String val) {
    if (val.isEmpty) {
      setState(() {
        _passwordErrorMessage = "Password cannot be empty";
      });
    } else if (val.length < 6) {
      setState(() {
        _passwordErrorMessage = "Password should be greater than 6 characters";
      });
    } else {
      setState(() {
        _passwordErrorMessage = "";
      });
    }
  }

  void checkIfMatched() {
    print(signUpController.password);
    print(_confirmPassword);
    print(signUpController.password != _confirmPassword);
    if (signUpController.password != signUpController.confirmPassword) {
      setState(() {
        _passwordMatched = false;
        _passwordErrorMessage = "Password don't match with each other";
      });
    } else {
      setState(() {
        _passwordMatched = true;
        _passwordErrorMessage = "";
      });
    }
  }
  //   _getLocations(pincode) {

  //   final JsonDecoder _decoder = const JsonDecoder();
  //   http.get(Uri.parse("http://www.postalpincode.in/api/pincode/$pincode"))
  //       .then((http.Response response) {
  //     final String res = response.body;
  //     final int statusCode = response.statusCode;
  //     print(res);
  //     print(statusCode);

  //     if (statusCode < 200 || statusCode > 400) {
  //       throw Exception("Error while fetching data");
  //     }

  //   });
  // }
}
