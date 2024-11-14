import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:hortijoy_mobile_app/resources/my_button.dart';
import 'package:hortijoy_mobile_app/resources/my_textfield.dart';
import 'package:hortijoy_mobile_app/custom_widgets/custom_circular_icons.dart';
import 'package:hortijoy_mobile_app/resources/shared_pref_service.dart';
import 'package:hortijoy_mobile_app/screens/forgot_password/forgot_password_screen.dart';
import 'package:hortijoy_mobile_app/screens/home/home_page_body.dart';
import 'package:hortijoy_mobile_app/screens/registration/registration_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animated_snack_bar/animated_snack_bar.dart';

class LoginBodyScreen extends StatefulWidget {
  const LoginBodyScreen({super.key});

  @override
  State<LoginBodyScreen> createState() => _LoginBodyScreenState();
}

class _LoginBodyScreenState extends State<LoginBodyScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  bool isLoading = false;

  void signUserIn() async {
    try {
      setState(() {
        isLoading = true;
      });
      UserCredential? userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailController.text, password: passwordController.text);

      if (userCredential != null) {
        setState(() {
          isLoading = false;
        });
        SharedPreferenceService.setLoggedInUserEmail(emailController.text);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreenBody()),
        );
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });
      showErrorMessage(e.code, e.message.toString());
    }
  }

  void showErrorMessage(String code, String message) {
    if (code == "user-not-found") {
      setState(() {
        AnimatedSnackBar.material(
          'User not found',
          type: AnimatedSnackBarType.error,
          mobileSnackBarPosition: MobileSnackBarPosition
              .top, // Position of snackbar on mobile devices
          desktopSnackBarPosition: DesktopSnackBarPosition
              .bottomCenter, // Position of snackbar on desktop devices
        ).show(context);
      });
    } else {
      setState(() {
        AnimatedSnackBar.material(
          message,
          type: AnimatedSnackBarType.error,
          mobileSnackBarPosition: MobileSnackBarPosition
              .top, // Position of snackbar on mobile devices
          desktopSnackBarPosition: DesktopSnackBarPosition
              .bottomCenter, // Position of snackbar on desktop devices
        ).show(context);
      });
    }
  }

  String _errorMessage = "";

  void validateEmail(String val) {
    if (val.isEmpty) {
      setState(() {
        _errorMessage = "Email can not be empty";
      });
    } 
    // else if (!EmailValidator.validate(val, true)) {
    //   setState(() {
    //     _errorMessage = "Invalid Email Address";
    //   });
    // } 
    else {
      setState(() {
        _errorMessage = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.white,
      body: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                height: 350,
                width: 350,
                child: Image.asset(
                  'assets/images/leaves_background_signin.png',
                  scale: 1,
                ),
              )),
          Center(
              child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        "SIGN IN",
                        style: GoogleFonts.openSans(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30, 0, 30, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            MyTextField(
                              onChanged: (() {
                                validateEmail(emailController.text);
                              }),
                              controller: emailController,
                              hintText: "Email",
                              obscureText: false,
                              prefixIcon: const Icon(Icons.mail_outline),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: Text(
                                _errorMessage,
                                style: GoogleFonts.openSans(
                                  fontSize: 12,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                            TextField(
                              obscureText: !_isPasswordVisible,
                              controller: passwordController,
                              cursorColor: HexColor("#4f4f4f"),
                              decoration: InputDecoration(
                                hintText: "Password",
                                contentPadding:
                                    const EdgeInsets.fromLTRB(0, 0, 20, 0),
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
                            // MyTextField(
                            //   controller: passwordController,
                            //   hintText: "Password",
                            //   obscureText: true,
                            //   prefixIcon: const Icon(Icons.lock_outline),
                            //   suffixIcon: IconButton(
                            //   icon: Icon(
                            //     _isPasswordVisible
                            //         ? Icons.visibility
                            //         : Icons.visibility_off,
                            //   ),
                            //   onPressed: () {
                            //     setState(() {
                            //       _isPasswordVisible = !_isPasswordVisible;
                            //     });
                            //   },
                            // ),
                            // ),
                            const SizedBox(
                              height: 20,
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
                                  'Sign In',
                                  style: GoogleFonts.openSans(
                                    color: AppColors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )),
                              ),
                              onTap: () {
                                signUserIn();
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            GestureDetector(
                              child: Text(
                                "Forgot Password?",
                                style: GoogleFonts.openSans(
                                    fontSize: 16,
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.w500),
                              ),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgotPasswordScreen(),
                                ),
                              ),
                            ),
                            SizedBox(height: 30),
                            // Row(
                            //   children: [
                            //     Expanded(
                            //       child: Divider(
                            //         color: Colors.black,
                            //         thickness: 0.5,
                            //       ),
                            //     ),
                            //     Padding(
                            //       padding:
                            //           EdgeInsets.symmetric(horizontal: 8.0),
                            //       child: Text("OR"),
                            //     ),
                            //     Expanded(
                            //       child: Divider(
                            //         color: Colors.black,
                            //         thickness: 0.5,
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            // const SizedBox(
                            //   height: 30,
                            // ),
                            // Container(
                            //   height: 42,
                            //   width: double.infinity,
                            //   decoration: BoxDecoration(
                            //     color: AppColors.white,
                            //     border: Border.all(
                            //         style: BorderStyle.solid,
                            //         color: Colors.black),
                            //     borderRadius: BorderRadius.circular(30.0),
                            //   ),
                            //   child: Center(
                            //     child: Row(
                            //         mainAxisAlignment: MainAxisAlignment.center,
                            //         crossAxisAlignment:
                            //             CrossAxisAlignment.center,
                            //         children: [
                            //           Image.asset(
                            //               "assets/icons/google_icon.png"),
                            //           SizedBox(width: 10),
                            //           Text('Sign In with Google',
                            //               style: GoogleFonts.openSans(
                            //                 color: AppColors.black,
                            //                 backgroundColor: AppColors.white,
                            //                 fontSize: 16,
                            //                 fontWeight: FontWeight.w500,
                            //               ))
                            //         ]),
                            //   ),
                            // ),
                            // const SizedBox(
                            //   height: 20,
                            // ),
                            // Container(
                            //   height: 42,
                            //   width: double.infinity,
                            //   decoration: BoxDecoration(
                            //     color: AppColors.white,
                            //     border: Border.all(style: BorderStyle.solid),
                            //     borderRadius: BorderRadius.circular(30.0),
                            //   ),
                            //   child: Center(
                            //     child: Row(
                            //         mainAxisAlignment: MainAxisAlignment.center,
                            //         crossAxisAlignment:
                            //             CrossAxisAlignment.center,
                            //         children: [
                            //           Icon(
                            //             Icons.facebook,
                            //             color: Colors.blue,
                            //           ),
                            //           SizedBox(width: 10),
                            //           Text('Sign In with Facebook',
                            //               style: GoogleFonts.openSans(
                            //                 color: AppColors.black,
                            //                 backgroundColor: AppColors.white,
                            //                 fontSize: 16,
                            //                 fontWeight: FontWeight.w500,
                            //               ))
                            //         ]),
                            //   ),
                            // ),
                            // const SizedBox(
                            //   height: 15,
                            // ),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text("Don't have an account?",
                                      style: GoogleFonts.openSans(
                                        fontSize: 15,
                                        color: HexColor("#8d8d8d"),
                                      )),
                                  SizedBox(width: 10),
                                  GestureDetector(
                                    child: Text(
                                      "Sign Up",
                                      style: GoogleFonts.openSans(
                                          fontSize: 15,
                                          color: AppColors.primaryColor,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const RegistrationScreen(),
                                      ),
                                    ),
                                  ),
                                ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
          if (isLoading)
            Container(
              color: Colors.white,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
        ],
      ),
    );
  }
}
